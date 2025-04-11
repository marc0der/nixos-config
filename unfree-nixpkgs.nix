{ lib }:
{
  allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "code-cursor"
    "claude-code"
    "cursor"
    "vscode"
    "obsidian"
    "idea-ultimate"
    "protonvpn-gui"
  ];
}