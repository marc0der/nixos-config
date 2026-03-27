{ lib }:
{
  allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "code-cursor"
      "claude-code"
      "copilot-cli"
      "cursor"
      "discord"
      "vscode"
      "obsidian"
      "idea"
      "protonvpn-gui"
      "transcribe"
    ];
}
