import xhvm.VMManager;
import core.sys.posix.pwd,
       core.sys.posix.unistd;
import std.string,
       std.stdio,
       std.conv,
       std.file;

void help() {}

void main(string[] args) {
  args = args[1..$];

  VMManager manager;
  string ossPath;

  if (args.length) {
    manager = new VMManager;

    ossPath = "/Users/" ~ getpwuid(geteuid).pw_name.to!string ~ "/xhyve-oss/";
    if (!exists(ossPath)) {
      mkdir(ossPath);
    }

  }

  switch (args.length) {
    case 1:
      switch (args[0]) {
        case "list":
          writeln("VM List:");
          foreach (vmName, running; manager.getVMStatusList) {
            writefln("* [%s] - %s", vmName, running ? "running" : "stop");
          }
          break;
        default:
          break;
      }
      break;
    case 2:
      switch (args[0]) {
        case "setup":
          string vmName = args[1];
          if (manager.existVM(vmName)) {
            writeln("Setup VM - ", vmName);
            
            manager.setupVM(vmName);

            write("Are you going to continue to Install process? [Y/N]: ");
            string input = readln.chomp;
            if (input == "Y" || input == "y") {
              writeln("=> Continue to Install Process");
              manager.installVM(vmName);
            }
          } else {
            writeln("[Error] - No such VM: " ~ vmName);
          }
          break;
        case "install":
          string vmName = args[1];
          if (manager.existVM(vmName)) {
            writeln("Install VM - ", vmName);

            manager.installVM(vmName);
          } else {
            writeln("[Error] - No such VM: " ~ vmName);
          }
          break;
        case "run":
          string vmName = args[1];
          if (manager.existVM(vmName)) {
            writeln("Run VM - ", vmName);

            manager.runVM(vmName);
          } else {
            writeln("[Error] - No such VM: " ~ vmName);
          }
          break;
        case "new":
          string vmName = args[1],
                 vmPath = ossPath ~ vmName ;
          writeln("Create new VM - ", vmName);

          if (!exists(vmPath)) {
            mkdir(vmPath);

            string configSkeleton = `{
"common": {
  "ISO": "",
  "HDD": "",
  "MEM": "",
  "SMP": "",
  "NET": "",
  "PCI_DEV": "",
  "LPC_DEV": ",
  "ACPI": ""
},
  "setup": {
    "KERNEL_PATH": "",
    "INITRD_PATH": "",
    "HDD_BS": "",
    "HDD_COUNT": ""
  },
  "install": {
    "KERNEL": "",
    "INITRD": "",
    "CMDLINE": ""
  },
  "run": {
    "KERNEL": "",
    "INITRD": "",
    "CMDLINE": ""
  }
}`;

            File(vmPath ~ "/config.json", "w").write(configSkeleton);

            writeln("A config file \"" ~ vmPath ~ "/config.json\" is generated");
            writeln("Please configure it like sampleConfig.json");
          } else {
            writeln("[Error] - The VM \"" ~ vmName ~ "\" is already exists. Please change VM name." );
          }
          break;
        default:
          break;
      }
      break;
    default:
      help;
      break;
  }
}
