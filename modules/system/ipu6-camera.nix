# Intel IPU6 MIPI camera
#
# Drives the IPU6 sensor through libcamera's software ISP and republishes it as
# a single V4L2 device. The kernel side is entirely in-tree as of 7.2.
#
# The ISYS hardware exposes ~48 raw capture nodes, which are libcamera's input
# rather than cameras in their own right. Applications that enumerate
# /dev/video* directly (Zoom, Firefox, Chromium without the PipeWire camera
# feature) would otherwise list all of them. They are restricted to root, and a
# root-side v4l2-relayd reads them via libcamera and writes one loopback node.
#
# Options:
#   local.hardware.ipu6-camera.enable           - Enable the IPU6 camera
#   local.hardware.ipu6-camera.videoDeviceNumber - Loopback node (default: 50)
#
# Example usage:
#   local.hardware.ipu6-camera.enable = true;
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.hardware.ipu6-camera;

  # Numbered 72- deliberately: systemd's 70-uaccess.rules tags every
  # video4linux and media device with uaccess, and 73-seat-late.rules turns
  # that tag into the ACL grant. The removal has to sit between the two.
  # services.udev.extraRules would land in 99-local.rules, far too late.
  rawNodeRules = pkgs.writeTextFile {
    name = "ipu6-raw-node-udev-rules";
    destination = "/etc/udev/rules.d/72-ipu6-raw-nodes.rules";
    text = ''
      # Intel IPU6 raw ISYS nodes - libcamera's input, not cameras
      SUBSYSTEM=="media", DRIVERS=="intel-ipu6", MODE="0600", GROUP="root", TAG-="uaccess"
      SUBSYSTEM=="video4linux", DRIVERS=="intel-ipu6", MODE="0600", GROUP="root", TAG-="uaccess"
    '';
  };
in
{
  options.local.hardware.ipu6-camera = {
    enable = lib.mkEnableOption "Intel IPU6 MIPI camera via libcamera";

    videoDeviceNumber = lib.mkOption {
      type = lib.types.int;
      default = 50;
      description = ''
        v4l2loopback device number for the relay output (`/dev/videoN`).

        Fixed so that PipeWire node names, and the application camera
        permission grants keyed to them, survive reboots. Must sit above the
        raw ISYS node range.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # `cam` for enumerating and test-capturing (needs root: see udev rules)
    environment.systemPackages = [ pkgs.libcamera ];

    # Hide the raw ISYS nodes from every application, not just PipeWire ones
    services.udev.packages = [ rawNodeRules ];

    # Belt and braces: keep the raw nodes out of PipeWire even if udev misses
    services.pipewire.wireplumber.extraConfig."10-ipu6-hide-raw-nodes" = {
      "monitor.v4l2.rules" = [
        {
          matches = [ { "device.product.name" = "ipu6"; } ];
          actions.update-props."device.disabled" = true;
        }
      ];
    };

    # libcamera software ISP -> v4l2loopback, for every V4L2 application
    services.v4l2-relayd.instances.ipu6 = {
      enable = true;
      cardLabel = "Integrated Camera";
      extraPackages = [ pkgs.libcamera ];
      input = {
        pipeline = "libcamerasrc ! video/x-raw,width=1280,height=720 ! videoconvert";
        format = "YUY2";
        width = 1280;
        height = 720;
        framerate = 30;
      };
      output.format = "YUY2";
    };

    # Pin the loopback node number; exit 17 (EEXIST) means it already exists
    systemd.services.v4l2-relayd-ipu6.preStart = lib.mkForce ''
      mkdir -p "$(dirname "$V4L2_DEVICE_FILE")"
      ${config.boot.kernelPackages.v4l2loopback.bin}/bin/v4l2loopback-ctl \
        add --name "Integrated Camera" --exclusive-caps=1 ${toString cfg.videoDeviceNumber} \
        || [ $? -eq 17 ]
      echo /dev/video${toString cfg.videoDeviceNumber} > "$V4L2_DEVICE_FILE"
    '';
  };
}
