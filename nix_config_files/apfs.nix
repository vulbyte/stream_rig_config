{ config, pkgs, ... }:

{
  # Add the APFS module to the kernel
  boot.extraModulePackages = [ config.boot.kernelPackages.apfs ];
  
  boot.initrd.kernelModules = [ "apfs" ];
  
  # Optional: adds support for mounting apfs in the userspace
  environment.systemPackages = [ pkgs.apfsprogs ];
}
