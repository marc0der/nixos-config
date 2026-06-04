{ pkgs, lib, ... }:

{
  home.activation.changesReport = lib.hm.dag.entryAnywhere ''
    ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
  '';
}
