{
  pkgs,
  homeDirectory,
  ...
}:

{
  programs.ssh =
    if pkgs.stdenv.isDarwin then
      {
        enable = true;
        matchBlocks.any-host = {
          host = "*";
          extraOptions.IdentityAgent =
            homeDirectory + "/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
        };
      }
    else {};
}
