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
  pname = "tokyo-night-sddm";
  version = "1..0";
  dontBuild = true;
  src = fetchFromGitHub {
    owner = "marc0der";
    repo = "tokyo-night-sddm";
    rev = "11644059b1ff3b0e1562246835f8f1a385f6cf0a";
    sha256 = "sha256-KG1dZ9tHE+dOwtczRW+zpZE3NLDPaMhtSg5RJ1GGKMs=";
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
    cp -aR $src $out/share/sddm/themes/tokyo-night-sddm
  '';

}
