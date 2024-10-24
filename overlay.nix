self: super:
let
  sources = builtins.fromJSON (builtins.readFile ./sources.json);

  mkFirefoxPackage = edition:
    super.stdenv.mkDerivation rec {
      inherit (sources."${edition}") version;
      pname = "Firefox";
      buildInputs = [ self.pkgs.undmg ];
      sourceRoot = ".";
      phases = [ "unpackPhase" "installPhase" ];

      installPhase = ''
        runHook preInstall

        mkdir -p $out/Applications
        cp -r Firefox*.app "$out/Applications/"

        runHook postInstall
      '';

      src = super.fetchurl {
        name = "Firefox-${version}.dmg";
        inherit (sources."${edition}") url sha256;
      };

      meta = {
        description = "Mozilla Firefox, free web browser (binary package)";
        homepage = "https://www.mozilla.com/firefox/";
      };
    };
in
{
  firefox-bin = mkFirefoxPackage "firefox";
}
