{
  programs = {
    git = {
      enable = true;
      settings = {
        user.email = "vermeulen.mp@gmail.com";
        user.name = "Marco Vermeulen";
        init.defaultBranch = "main";
        commit.gpgSign = true;
        core.autocrlf = "input";
        tag.gpgSign = true;
        pull.rebase = true;
      };
      signing.key = "E1C2A16A9D3C07D3E75FA13847F7ABD6F9FBD428";
    };
  };
}
