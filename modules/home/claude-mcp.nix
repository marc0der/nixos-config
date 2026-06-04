# Claude Code MCP server registration
#
# Activation script that registers MCP servers (git-mcp, github-mcp, sdkman)
# with Claude Code after every home-manager activation. Idempotent: it skips
# any server that's already registered. github-mcp needs
# $GITHUB_PERSONAL_ACCESS_TOKEN in the environment (sourced from
# ~/.config/secrets/env if present) and is silently skipped otherwise.
#
# Depends on the `llmAgents.claude-code` package being passed in via
# extraSpecialArgs from flake.nix.
#
# Options:
#   claude-mcp.enable - Register MCP servers with Claude Code on activation
#
# Example usage:
#   claude-mcp.enable = true;
{
  config,
  lib,
  llmAgents,
  ...
}:

let
  cfg = config.claude-mcp;
in
{
  options.claude-mcp = {
    enable = lib.mkEnableOption "Claude Code MCP server registration";
  };

  config = lib.mkIf cfg.enable {
    home.activation.setupClaudeMcpServers = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      echo "Configuring Claude MCP servers..."

      # Source secrets file if it exists
      [[ -f ~/.config/secrets/env ]] && source ~/.config/secrets/env

      # Use the full path to claude from the nix store
      CLAUDE_BIN="${llmAgents.claude-code}/bin/claude"

      # Configure git-mcp server
      if ! "$CLAUDE_BIN" mcp get git-mcp >/dev/null 2>&1; then
        echo "Adding git-mcp server..."
        "$CLAUDE_BIN" mcp add git-mcp -s user uvx mcp-server-git || echo "Failed to add git-mcp server"
      fi

      # Configure github-mcp server with environment variable
      if ! "$CLAUDE_BIN" mcp get github-mcp >/dev/null 2>&1; then
        echo "Adding github-mcp server..."
        if [[ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]]; then
          echo "Warning: GITHUB_PERSONAL_ACCESS_TOKEN environment variable not set"
          echo "Please set it in your shell profile or environment"
        else
          "$CLAUDE_BIN" mcp add github-mcp -e GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_PERSONAL_ACCESS_TOKEN" -s user npx @modelcontextprotocol/server-github || echo "Failed to add github-mcp server"
        fi
      fi

      # Configure sdkman-mcp server
      if ! "$CLAUDE_BIN" mcp get sdkman >/dev/null 2>&1; then
        echo "Adding sdkman-mcp server..."
        "$CLAUDE_BIN" mcp add sdkman -s user /home/marco/src/oss/sdkman-mcp-server/target/release/sdkman-mcp-server || echo "Failed to add sdkman-mcp server"
      fi

      echo "Claude MCP servers configured"
    '';
  };
}
