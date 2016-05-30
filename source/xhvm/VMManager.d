module xhvm.VMManager;

import xhvm.ConfigLoader,
       xhvm.VMMode,
       xhvm.VM;
import core.sys.posix.pwd,
       core.sys.posix.unistd;
import std.algorithm,
       std.array,
       std.conv,
       std.file;

class VMManager {
  string ossPath;
  
  this() {
    this.ossPath = "/Users/" ~ getpwuid(geteuid).pw_name.to!string ~ "/xhyve-oss/";
    if (!exists(this.ossPath)) {
      mkdir(this.ossPath);
    }
  }

  public bool existVM(string vmName) {
    return this.getVMList.canFind(vmName);
  }

  public void setupVM(string vmName) {
    string vmPath = ossPath ~ vmName;
    VM vm = new VM(vmName, ConfigLoader(VMMode.Setup, vmPath ~ "/config.json"));

    vm.setup;
  }

  public void installVM(string vmName) {
    string vmPath = ossPath ~ vmName;
    VM vm = new VM(vmName, ConfigLoader(VMMode.Install, vmPath ~ "/config.json"));

    vm.boot;
  }

  public void runVM(string vmName) {
    string vmPath = ossPath ~ vmName;
    chdir(vmPath);

    VM vm = new VM(vmName, ConfigLoader(VMMode.Run, vmPath ~ "/config.json"));
    vm.boot;
  }

  public string[] getVMList() {
    return dirEntries(ossPath, SpanMode.shallow)
            .filter!(a => a.isDir)
            .map!(a => std.path.baseName(a.name))
            .array;
  }

  public bool[string] getVMStatusList() {
    bool[string] list;

    foreach (vmName; this.getVMList) {
      list[vmName] = this.isRunning(vmName);
    }

    return list;
  }

  private bool isRunning(string vmName) {
    if (!this.existVM(vmName)) {
      throw new Exception("No such VM: " ~ vmName);
    }

    string path = ossPath ~ vmName;
    return exists(path ~ "/.running");
  }

}
