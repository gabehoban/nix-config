{ config, ... }:
{
  config = {
    topology.nodes.epson = {
      deviceType = "device";
      hardware.info = "Epson L4150 Printer";
      interfaces.wlan = {
        network = "home";
        addresses = [
          "espon.alq.ae"
          "192.168.1.52"
        ];
      };
    };
  };
}
