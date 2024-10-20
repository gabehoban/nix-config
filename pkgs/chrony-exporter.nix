{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "chrony-exporter";
  version = "v0.10.1";

  vendorHash = "sha256-HLSa0CvUgEaK8Htmgm5QWNRWAFZGALNPNLr2zeJwU3c=";

  src = fetchFromGitHub {
    owner = "superq";
    repo = "chrony_exporter";
    rev = version;
    hash = "sha256-EDYvC3tucGzLb+OxCA8yiVsPU8ai3bXTzzp39qIsAr8=";
  };

  meta = with lib; {
    description = "Exporter for Chrony NTP";
    homepage = "https://github.com/SuperQ/chrony_exporter";
    license = licenses.asl20;
    mainProgram = "chrony_exporter";
    maintainers = with maintainers; [
      superq
    ];
  };
}
