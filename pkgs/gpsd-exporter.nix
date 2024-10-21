{
  lib,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "gpsd-exporter";
  version = "v0.0.1";

  cargoLock.lockFile = ./gpsd-exporter/Cargo.lock;
  src = lib.cleanSource ./gpsd-exporter/.;

  meta = with lib; {
    description = " Export gpsd metrics to Prometheus";
    homepage = "https://github.com/natesales/gpsd-exporter";
    license = licenses.mit;
    mainProgram = "gpsd_exporter";
    maintainers = with maintainers; [
      natesales
    ];
  };
}
