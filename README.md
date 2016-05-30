#xhvm
The Xhyve VM Manager

#Requirements
* xhyve
* dmd >= v2.070
* dub >= 0.9.25

#How to use
## 1.Create new VM(preparing)
Execute `$ xhvm new <VM NAME>`, then a directory as `~/xhyve-oss/<VM NAME>` and a config file `config.json` will be created.  
Please edit the config file like `sampleConfig.json`.  
`sampleConfig.json` is author's config for ArchLinux.  
You can config HDD size by block size and count.  
  
*Note: If you want 5GB HDD image, you should config as `"HDD_BS":"1g"`, `"HDD_COUNT":"5"`.*  
  
## 2.Setup the VM(create HDD image and extract vmlinuz & initrd)
Execute `$ xhvm setup <VM NAME>`, then create HDD image and extract vmlinuz and initrd process will be done automatically.  
  
  
*Note: When you boot VM, this program urge password but this is for execute xhyve with root privilege*
  
## 3.Boot for Installation
Execute `$ xhvm install <VM NAME>`, then boot for Installation.
  
## Run
Now that installation has been finished, You can boot VM anytime.  
Execute `$ xhvm run <VM NAME>`, then boot.  

## Check vm List and VM status whether running or not
Execute `$ xhvm list`  


#License
MIT License.  See `LICENSE` file for the detail.
