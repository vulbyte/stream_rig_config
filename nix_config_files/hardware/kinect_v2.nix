# kinect2.nix
# NixOS configuration module for Kinect v2 (libfreenect2)
# Import this in your configuration.nix:
#   imports = [ ./kinect2.nix ];

{ config, pkgs, lib, ... }:

{
  # ── libfreenect2 overlay ───────────────────────────────────────────────────
  # libfreenect2 (Kinect v2 driver) is NOT in nixpkgs.
  # Only libfreenect (v1, Xbox 360 Kinect) is packaged there.
  # We build it from source via an inline overlay.
  nixpkgs.overlays = [
    (final: prev: {
      libfreenect1 = prev.stdenv.mkDerivation rec {
        pname = "libfreenect1";
        version = "0.2.1";

        src = prev.fetchFromGitHub {
          owner  = "OpenKinect";
          repo   = "libfreenect2";
          rev    = "v${version}";
          sha256 = "159f50kyphag82fvkqph4fd9w90mls8mc82rmyq06kab3y4m1qxz";
        };

        nativeBuildInputs = with prev; [ cmake pkg-config ];

        buildInputs = with prev; [
          libusb1
          libjpeg_turbo
          libGL
          libGLU
          glfw
        ];

        cmakeFlags = [
          "-DCMAKE_BUILD_TYPE=Release"
          "-DENABLE_OPENCL=OFF"   # set to ON if you have ocl-icd installed
          "-DENABLE_CUDA=OFF"
          "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"  # libfreenect2 0.2.1 predates CMake 3.5 policy
          "-DBUILD_EXAMPLES=ON"   # builds Protonect test viewer
        ];

        meta = {
          description = "Open source driver for the Kinect for Windows v2 (K4W2)";
          homepage    = "https://github.com/OpenKinect/libfreenect2";
          license     = prev.lib.licenses.asl20;
          platforms   = prev.lib.platforms.linux;
        };
      };
    })
  ];

  # ── Packages ───────────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    libfreenect2      # Built via overlay above — Kinect v2 driver
    libusb1           # USB access backend
    libjpeg_turbo     # JPEG decoding for the RGB stream
    # Optional: OpenCL support for GPU-accelerated depth processing
    # ocl-icd          # OpenCL ICD loader
    # clinfo           # Verify OpenCL stack (run `clinfo` to check)
  ];

  # ── OpenGL (required for depth processing pipeline) ────────────────────────
  # libfreenect2 requires OpenGL 3.1+ for its default depth pipeline.
  # NixOS 24.11+ replaced hardware.opengl with hardware.graphics.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # Only needed if running 32-bit apps alongside
  };

	 # # ── USB memory buffer (critical for Kinect v2 USB 3.0 isochronous transfer) ─
	 # # The Kinect v2 RGB stream is ~40 MB/s; the default usbfs limit is too low.
	 # boot.kernelParams = [
	 #   "usbcore.usbfs_memory_mb=256"
	 # ];

	  #$ # Disable USB autosuspend globally — autosuspend breaks the Kinect stream.
	  #$ powerManagement.enable = true;
	  #$ services.udev.extraRules = ''
	  #$   # ── Kinect v2 (Microsoft Xbox One Kinect) udev rules ──────────────────────
	  #$   # Vendor: 045e (Microsoft), Product IDs: 02c4, 02d8 (Kinect v2), 02d9 (audio)
	  #$   #
	  #$   # Grants read/write access to members of the "video" group without requiring
	  #$   # root. Make sure your user account is in the "video" group:
	  #$   #   users.users.<yourName>.extraGroups = [ "video" ];

	  #$   SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02c4", \
	  #$     MODE:="0666", OWNER:="root", GROUP:="video"

	  #$   SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02d8", \
	  #$     MODE:="0666", OWNER:="root", GROUP:="video"

	  #$   SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02d9", \
	  #$     MODE:="0666", OWNER:="root", GROUP:="video"

	  #$   # Disable USB autosuspend for the Kinect v2 specifically
	  #$   SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02c4", \
	  #$     ATTR{power/autosuspend}="-1"
	  #$   SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02d8", \
	  #$     ATTR{power/autosuspend}="-1"
	  #$   SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02d9", \
	  #$     ATTR{power/autosuspend}="-1"
	  #$ '';
}
