{ lib }:
{
  allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "code-cursor"
      "claude-code"
      "cursor"
      "discord"
      "vscode"
      "obsidian"
      "idea"
      "protonvpn-gui"
      "transcribe"
    ];
}
