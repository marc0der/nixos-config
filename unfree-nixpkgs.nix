{ lib }:
{
  allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
      "copilot-cli"
      "discord"
      "vscode"
      "obsidian"
      "idea"
      "protonvpn-gui"
      "transcribe"
    ];
}
