{
  # Enable sound with Pipewire
  security.rtkit.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    extraConfig.pipewire."99-rates" = {
      "context.properties" = {
        "default.clock.rate" = 96000;
        "default.clock.allowed-rates" = [
          44100
          48000
          88200
          96000
        ];
      };
    };
    wireplumber.extraConfig."99-stop-microphone-auto-adjust" = {
      "access.rules" = [
        {
          matches = [
            { "application.process.binary" = "chrome"; }
            { "application.process.binary" = "electron"; }
          ];
          actions.update-props.default_permissions = "rx";
        }
      ];
    };
  };
}
