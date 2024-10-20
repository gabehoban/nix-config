{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
}:
let
  src = fetchFromGitHub {
    owner = "brendanbank";
    repo = "gpsd-prometheus-exporter";
    rev = "f4dd7340aa6f8760acf8fef487f63e26f7f432fe";
    hash = "sha256-kWnDdYHIMj2MSwY+wlb0XpqEKi+wa+OOp/SM77S0OzY=";
  };
in
stdenv.mkDerivation {
  name = "gpsd-prometheus-exporter";
  inherit src;

  strictDeps = true;
  buildInputs = [ bash ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src/gpsd_exporter.py $out/bin/
  '';

  meta = with lib; {
    description = "Prometheus exporter for the gpsd GPS daemon.";
    homepage = "https://github.com/brendanbank/gpsd-prometheus-exporter";
    license = licenses.bsd3;
    mainProgram = "gpsd-prometheus-exporter";
    maintainers = with maintainers; [
      brendanbank
    ];
  };
}
