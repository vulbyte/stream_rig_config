{ config, pkgs, ... }:

{
	systemd.services.lact = {
		description = "intelGPU Control Daemon";
		after = ["multi-user.target"];
		wantedBy = ["multi-user.target"];
		serviceConfig = {
			ExecStart = "${pkgs.lact}/bin/lact daemon";
		};
		enable = true;
	};
	hardware.cpu.intel.updateMicrocode = true; #lib.mkDefault;

  # 1. Force the Xe driver for Battlemage (Device e20b)
  # We block the i915 driver from touching it to prevent driver conflicts.
  boot.kernelParams = [
    #"xe.force_probe=e20b"
    #"i915.force_probe=!e20b"
    # Optional: Enable Resizable BAR support if your BIOS supports it
    # "xe.vram_bar_size=12288" 
  ];

  # 2. Graphics Driver and Acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Necessary for Steam/Wine
    extraPackages = with pkgs; [
      intel-media-driver   # Hardware Video Acceleration (VA-API)
      intel-compute-runtime # OpenCL support for Blender/Darktable
      vpl-gpu-rt          # Essential for QSV on Battlemage/B580
      vulkan-loader
      vulkan-validation-layers
    ];
  };

  # 3. Necessary Firmware
  # The B580 requires specific 'bmg' firmware files (GuC/HuC) found in recent linux-firmware.
  hardware.firmware = [ pkgs.linux-firmware ];

  # 4. Power Management (Optional)
  # Intel Arc cards can sometimes draw high idle power; this helps with ASPM.
  boot.kernel.sysctl = {
    "pcie_aspm" = "force";
  };

  services.xserver.videoDrivers = [ "intel" ];
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # prefer modern iHD backend
  };
  #services.xserver.extraGroups = ["video"]; #POTENTIAL
}
