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
  pname = "simple-sddm";
  version = "1..0";
  dontBuild = true;
  src = fetchFromGitHub {
    owner = "JaKooLit";
    repo = "simple-sddm";
    rev = "afd038e57f8c678a14adf3fd9407a44dde5a660b";
    sha256 = "sha256-N04pHKLge228dQDFD1jAAymUf8BUg1N+CX9+91DMHvY=";
  };
  nativeBuildInputs = [
    wrapQtAppsHook
  ];

  propagatedUserEnvPkgs = [
    qtbase
    qtsvg
    qtgraphicaleffects
    qtquickcontrols2
  ];

  installPhase = ''
    mkdir -p $out/share/sddm/themes
    cp -aR $src $out/share/sddm/themes/simple-sddm
  '';

}
