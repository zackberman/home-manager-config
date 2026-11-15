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
        enableDefaultConfig = false;
        settings."*" = {
          IdentityAgent =
            homeDirectory + "/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";

          ForwardAgent = false;
          AddKeysToAgent = "no";
          Compression = false;
          ServerAliveInterval = 0;
          ServerAliveCountMax = 3;
          HashKnownHosts = false;
          UserKnownHostsFile = "~/.ssh/known_hosts";
          ControlMaster = "no";
          ControlPath = "~/.ssh/master-%r@%n:%p";
          ControlPersist = "no";
        };
      }
    else {};
}
