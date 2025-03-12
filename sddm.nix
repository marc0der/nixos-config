{
  lib,
  qtbase,
  qtsvg,
  qtgraphicaleffects,
  qtquickcontrols2,
  wrapQtAppsHook,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation rec {
  pname = "simple-sddm-2";
  version = "1..0";
  dontBuild = true;
  src = fetchFromGitHub {
    owner = "JaKooLit";
    repo = "simple-sddm-2";
    rev = "84ae7ad47eab5daa9d904b2e33669788d891bd3d";
    sha256 = "sha256-BkqtSh944QIVyYvXCCU8Pucs/2RpWXlwNFSC9zVlRoc=";
  };
  nativeBuildInputs = [
    wrapQtAppsHook
  ];

  propagatedUserEnvPkgs = [
    qtbase
    qtsvg
    qtdeclarative
    qt5compat
    qtgraphicaleffects
    qtquickcontrols2
  ];

  installPhase = ''
    mkdir -p $out/share/sddm/themes
    cp -aR $src $out/share/sddm/themes/simple-sddm-2
  '';

}
