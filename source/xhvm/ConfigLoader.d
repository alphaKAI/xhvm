module xhvm.ConfigLoader;

import xhvm.VMOptions,
       xhvm.VMOption,
       xhvm.VMMode;
import std.stdio,
       std.file,
       std.path,
       std.json;

VMOption detectOption(string key) {
  VMOption option;
  with (VMOption) final switch (key) {
    case "HDD":
      option = HDD;
      break;
    case "HDD_BS":
      option = HDD_BS;
      break;
    case "HDD_COUNT":
      option = HDD_COUNT;
      break;
    case "ISO":
      option = ISO;
      break;
    case "KERNEL":
      option = KERNEL;
      break;
    case "KERNEL_PATH":
      option = KERNEL_PATH;
      break;
    case "INITRD":
      option = INITRD;
      break;
    case "INITRD_PATH":
      option = INITRD_PATH;
      break;
    case "CMDLINE":
      option = CMDLINE;
      break;
    case "MEM":
      option = MEM;
      break;
    case "SMP":
      option = SMP;
      break;
    case "NET":
      option = NET;
      break;
    case "PCI_DEV":
      option = PCI_DEV;
      break;
    case "LPC_DEV":
      option = LPC_DEV;
      break;
    case "ACPI":
      option = ACPI;
      break;
  }

  return option;
}

VMOptions ConfigLoader(VMMode mode, string path) {
  VMOptions options = new VMOptions;

  if (!exists(path)) {
    throw new Exception("No such a file : ", path);
  }

  JSONValue jv = parseJSON(readText(path));
  
  if ("common" in jv) {
    foreach (key, value; jv.object["common"].object) {
      options.set(detectOption(key), value.str);
    }
  }

  string[] modeStrs;

  with(VMMode) final switch (mode) {
    case Setup:
      modeStrs = ["setup", "install"];
      break;
    case Install:
      modeStrs = ["install"];
      break;
    case Run:
      modeStrs = ["run"];
      break;
  }

  foreach (modeStr; modeStrs) {
    if (modeStr in jv.object) {
      foreach (key, value; jv.object[modeStr].object) {
        options.set(detectOption(key), value.str);
      }
    } else {
      throw new Exception("There is no " ~ modeStr ~ " section in the config file. " ~ "Config file must have <run and install> section.");
    }
  }

  return options;
}
