module xhvm.VM;

import xhvm.VMOptions,
       xhvm.VMOption,
       xhvm.VMMode;
import core.sys.posix.pwd,
       core.sys.posix.unistd;
import std.algorithm,
       std.process,
       std.string,
       std.array,
       std.stdio,
       std.conv;

class VM {
  private string    ossPath;
  public  string    name;
  public  VMMode    mode;
  public  VMOptions options;

  this(string vmName, VMOptions vmOptions) {
    this.ossPath = "/Users/" ~ getpwuid(geteuid).pw_name.to!string ~ "/xhyve-oss/";
    this.name    = vmName;
    this.options = vmOptions;
  }

  public void setup() {
    with(VMOption) {
      enum VMOption[] requiredOptions = [
        ISO,
        HDD,
        HDD_BS,
        HDD_COUNT,
        KERNEL_PATH,
        INITRD_PATH
      ];

      if (!requiredOptions.all!(option => this.options.ConfiguredOptions.canFind(option))) {
        throw new Exception("The config file must have setup section and <" ~ requiredOptions.map!(op => op.stringof).join(", ") ~ "> values in it");
      }
    }

    std.file.chdir(this.ossPath ~ this.name);

    {
      writeln("fixing disk");
      execShell("dd if=/dev/zero bs=2k count=1 of=tmp.iso");
      execShell("dd if=" ~ this.options.getOption(VMOption.ISO) ~ " bs=2k skip=1 >> tmp.iso");
    }

    string disk,
           mnt;

    {
      writeln("-------------------------------------------");
      writeln("mounting disk");
      string diskinfo = pipeShell("hdiutil attach tmp.iso").stdout.byLine.map!(x => x).array[0].to!string;
      disk = pipeShell(`echo ` ~ diskinfo ~ ` |  cut -d' ' -f1`).stdout.byLine.map!(x => x).array[0].to!string;
      mnt  = pipeShell(`echo ` ~ diskinfo ~ ` | perl -ne '/(\/Volumes.*)/ and print $1'`).stdout.byLine.map!(x => x).array[0].to!string;
      
      writeln("mounted as " ~ disk ~ " at " ~ mnt);

      writeln("-------------------------------------------");
      writeln("extracting kernel");
      execShell("ls -l " ~ mnt ~ "/arch/boot/x86_64");
      execShell("cp " ~ mnt ~ this.options.getOption(VMOption.KERNEL_PATH) ~ " .");
      execShell("cp " ~ mnt ~ this.options.getOption(VMOption.INITRD_PATH) ~ " .");
      execShell("diskutil eject " ~ disk);
    }

    {
      writeln("creating hdd");
      execShell("dd if=/dev/zero of=hdd.img bs=" ~ this.options.getOption(VMOption.HDD_BS) ~ " count=" ~ this.options.getOption(VMOption.HDD_COUNT));
    }

  }

  public void boot() {
    string bootCommand = buildArgs(buildArgsHash(this.options));
//    writeln("bootCommand: ", bootCommand);

    writeln("[xhvm - BOOT] : " ~ name);
    std.stdio.File(".running", "w").write;
//    writeln("getcwd: ", std.file.getcwd);

    std.file.chdir(this.ossPath ~ this.name);
    execShell(bootCommand);
    
    std.file.remove(".running");
    writeln("[xhvm - Shutdown] : " ~ name);
  }

  private void execShell(string commandString) {
    spawnShell(commandString).wait;
  }

  private string[string] buildArgsHash(VMOptions options) {
    string[string] args;

    foreach (option; options.ConfiguredOptions) {
      with (VMOption) final switch (option) {
        case HDD:
          args["IMG_HDD"] = "-s 4,virtio-blk," ~ options.getOption(HDD);
          break;
        case HDD_BS: break;
        case HDD_COUNT: break;
        case KERNEL_PATH: break;
        case INITRD_PATH: break;
        case ISO:
          args["IMG_CD"]  = "-s 3,ahci-cd," ~ options.getOption(ISO);
          break;
        case KERNEL:
          args["KERNEL"]  = options.getOption(KERNEL);
          break;
        case INITRD:
          args["INITRD"]  = options.getOption(INITRD);
          break;
        case CMDLINE:
          args["CMDLINE"] = "\"" ~ options.getOption(CMDLINE) ~ "\"";
          break;
        case MEM:
          args["MEM"]     = "-m " ~ options.getOption(MEM);
          break;
        case SMP:
          args["SMP"]     = "-c " ~ options.getOption(SMP);
          break;
        case NET:
          args["NET"]     = "-s 2:0," ~ options.getOption(NET);
          break;
        case PCI_DEV:
          args["PCI_DEV"] = options.getOption(PCI_DEV);
          break;
        case LPC_DEV:
          args["LPC_DEV"] = options.getOption(LPC_DEV);
          break;
        case ACPI:
          args["ACPI"]    = options.getOption(ACPI);
          break;
      }
    }

    return args;
  }

  private string buildArgs(string[string] argsHash) {
    //sudo xhyve $ACPI $MEM $SMP $PCI_DEV $LPC_DEV $NET $IMG_HDD -f kexec,$KERNEL,$INITRD,"$CMDLINE"
    string   command    = "sudo xhyve ";
    string[] firstArgs  = ["ACPI", "MEM", "SMP", "PCI_DEV", "LPC_DEV", "NET", "IMG_CD", "IMG_HDD"];
    string[] secondArgs = ["KERNEL", "INITRD", "CMDLINE"]; 


    foreach (arg; firstArgs) {
      if (arg in argsHash) {
        command ~= argsHash[arg] ~ " ";
      }
    }

    command ~= "-f kexec," ~ secondArgs.map!(arg => argsHash[arg]).join(",");

    return command;
  }
}

