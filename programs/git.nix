{
  config,
  pkgs,
  ...
}: {
  enable = true;
  lfs.enable = true;
  settings = {
    user = {
      name = "Jan Baer";
      email = "jan.baer@check24.de";
    };
    pull = {
      rebase = true;
    };
    init = {
      defaultBranch = "main";
    };

    # url = {
    #   "git@github.com:" = {
    #     insteadOf = "https://github.com/";
    #   };
    # };
  };
}
