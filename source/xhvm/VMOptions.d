module xhvm.VMOptions;
import xhvm.VMOption;

class VMOptions {
  VMOption[] ConfiguredOptions;
  private string[VMOption] options;

  this() {}

  this(
      string[VMOption] options
  ) {
    this.options = options;
    ConfiguredOptions = options.keys;
  }

  public void set(
      VMOption option,
      string optionString
  ) {
    this.options[option] = optionString;
    ConfiguredOptions ~= option;
  }

  public void set(
      string[VMOption] options
  ) {
    foreach (option, optionString; options) {
      this.set(option, optionString);
    ConfiguredOptions ~= option;
    }
  }

  public string getOption(
      VMOption key
  ) {
    if (key in this.options) {
      return this.options[key];
    } else {
      throw new Exception("The option \"" ~ key.stringof ~ "\" is not configured.");
    }
  }
}
