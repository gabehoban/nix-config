{
  inputs,
  self,
  ...
}:
{
  flake.deploy.nodes = {
    vpsio = {
      hostname = "vpsio.gabehoban.lab4.cc";
      sshUser = "root";
      sshOpts = [
        "-p"
        "30"
      ];
      profiles.system = {
        path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.vpsio;
      };
    };
    sekio = {
      hostname = "sekio.gabehoban.lab4.cc";
      sshUser = "root";
      sshOpts = [
        "-p"
        "30"
      ];
      profiles.system = {
        path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.sekio;
      };
    };
  };
}
