# Disable Intel IPU6 integrated camera
#
# Blacklists the Intel IPU6 camera and its sensor modules. The IPU6 stack is
# unsupported on this kernel and its presence makes Zoom and similar apps
# fail to enumerate other webcams.
#
# Options:
#   hardware.disable-ipu6-camera.enable - Blacklist Intel IPU6 camera modules
#
# Example usage:
#   hardware.disable-ipu6-camera.enable = true;
{
  config,
  lib,
  ...
}:

let
  cfg = config.hardware.disable-ipu6-camera;
in
{
  options.hardware.disable-ipu6-camera = {
    enable = lib.mkEnableOption "Intel IPU6 camera blacklist";
  };

  config = lib.mkIf cfg.enable {
    boot.blacklistedKernelModules = [
      "intel_ipu6"
      "intel_ipu6_isys"
      "intel_ipu6_psys"
      "ipu_bridge"
      "ov08x40"
      "ov01a10"
      "ov02c10"
      "hm11b1"
      "intel_skl_int3472_common"
      "intel_skl_int3472_discrete"
      "intel_skl_int3472_tps68470"
    ];
  };
}
