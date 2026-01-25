{ config, pkgs, ... }:

{
  home.file = {
    ".p10k.zsh".source = ./powerline/p10k;
  };

  programs.zsh = {
    enable = true;
    initContent = ''
      # Source secrets file if it exists
      [[ -f ~/.config/secrets/env ]] && source ~/.config/secrets/env

      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source ${pkgs.autojump}/share/autojump/autojump.zsh
      [ -f ${config.home.homeDirectory}/.sdkman/bin/sdkman-init.sh ] && source ${config.home.homeDirectory}/.sdkman/bin/sdkman-init.sh
      (cat ~/.cache/wal/sequences &)
      export PYENV_ROOT=${config.home.homeDirectory}/.pyenv
      export PATH=$PYENV_ROOT/bin:$PATH
      eval "$(pyenv init --path)"
      eval "$(pyenv init -)"

      claude-oneshot() {
        if [[ -z "$1" ]]; then
          echo "Error: claude-oneshot requires a file path parameter" >&2
          return 1
        fi
        if [[ ! -f "$1" ]]; then
          echo "Error: File '$1' does not exist or is not a regular file" >&2
          return 1
        fi
        claude --dangerously-skip-permissions "$1"
      }
    '';
    shellAliases = {
      #nix
      nix-gc = "nix-collect-garbage";

      # general
      gco = "git checkout";
      gcob = "git checkout -b";
      ga = "git add";
      gaa = "git add .";
      gap = "git add -p";
      gs = "git status";
      gd = "git diff";
      gdt = "git difftool";
      gl = "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      gc = "git commit --verbose";
      gcm = "git commit --message --verbose";
      gca = "git commit --amend --verbose";
      gpusho = "git push origin";
      gpushob = "git push --set-upstream origin";
      gpushof = "git push --force origin";
      gpullo = "git pull --rebase origin";
      gfo = "git fetch origin";
      gr = "git rebase";
      gst = "git stash";
      gsta = "git stash apply";
      gstp = "git stash pop";
      gstl = "git stash list";

      hyprcfg = "nvim ~/.config/hypr/hyprland.conf";
      swaycfg = "nvim ~/.config/sway/config";
      open = "xdg-open";
      vi = "nvim";
      vim = "nvim";
      suvi = "pkexec nvim";
      ll = "ls -lah";
    };
    history = {
      size = 100000;
    };
    oh-my-zsh = {
      enable = true;
      plugins = [
        "fzf"
        "gh"
        "git"
        "docker"
        "sudo"
        "aws"
        "doctl"
        "per-directory-history"
      ];
      theme = "wezm+";
    };
  };
}
