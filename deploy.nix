{
  inputs,
  self,
  ...
}:
{
  flake.deploy.nodes = {
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
