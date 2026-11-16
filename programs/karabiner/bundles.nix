rec {
  hypervisors = [
    "^org\\.virtualbox\\.app\\.VirtualBoxVM$"
    "^com\\.parallels\\.desktop\\.console$"
    "^org\\.vmware\\.fusion$"
  ];
  ides = [
    "^org\\.gnu\\.emacs$"
    "^com\\.jetbrains\\.intellij\\.ce$"
    "^com\\.jetbrains\\.PhpStorm$"
    "^com\\.jetbrains\\.pycharm$"
    "^com\\.jetbrains\\.rider$"
    "^com\\.microsoft\\.VSCode$"
  ];
  citrix = [
    "^com\\.citrix\\.XenAppViewer$"
    "^com\\.citrix\\.receiver\\.icaviewer\\.mac$"
  ];
  remoteDesktops = citrix ++ [ "^com\\.microsoft\\.rdc\\.macos$" ];
  terminalEmulators = [
    "^org\\.alacritty$"
    "^co\\.zeit\\.hyper$"
    "^com\\.googlecode\\.iterm2$"
    "^com\\.apple\\.Terminal$"
  ];
  finder = [ "^com\\.apple\\.finder$" ];
  sublimeText = [ "^com\\.sublimetext\\.4$" ];
  standard = hypervisors ++ ides ++ remoteDesktops ++ terminalEmulators;
}
