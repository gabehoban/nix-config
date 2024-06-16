{ desktop, hostname, lib, pkgs, username, ... }:
let
  defaultDns = [ "10.32.40.51" "10.32.40.52" ];
  isGamestation = if (hostname == "baymax") && (desktop != null) then true else false;
  isInstall = if (builtins.substring 0 4 hostname != "iso-") then true else false;
  saveBattery = false;
in
{
  imports = lib.optional (builtins.pathExists (./. + "/${desktop}")) ./${desktop};

  boot = {
    kernelParams = [ "quiet" "vt.global_cursor_default=0" "mitigations=off" "threadirqs" ];
    plymouth = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; lib.optionals (isInstall) [
    appimage-run
    pavucontrol
    pulseaudio
    wmctrl
    xdotool
    ydotool
  ] ++ lib.optionals (isGamestation) [
    mangohud
  ] ++ lib.optionals (isInstall && isGamestation) [
    polychromatic
  ];

  fonts = {
    enableDefaultPackages = false;
    fontDir.enable = true;
    packages = with pkgs; [
      (nerdfonts.override { fonts = [
        "FiraCode"
        "Iosevka"
        "JetBrainsMono"
        "NerdFontsSymbolsOnly"
      ]; })
      ubuntu_font_family
      source-han-sans
      source-han-serif
      source-sans
      source-serif
      material-design-icons
      font-awesome
      noto-fonts-emoji
    ];

    fontconfig = {
      cache32Bit = true;
      defaultFonts = {
        serif = ["Source Han Serif SC" "Source Han Serif TC" "Noto Color Emoji"];
        sansSerif = ["Source Han Sans SC" "Source Han Sans TC" "Noto Color Emoji"];
        monospace = ["JetBrainsMono Nerd Font" "Noto Color Emoji"];
        emoji = ["Noto Color Emoji"];
      };
      enable = true;
    };
  };

  networking = {
    networkmanager = {
      dns = "systemd-resolved";
      enable = true;
      insertNameservers = defaultDns;
    };
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    pulseaudio.enable = lib.mkForce false;
    sane = lib.mkIf (isInstall) {
      enable = true;
      extraBackends = with pkgs; [ sane-airscan ];
    };
  };

  programs = {
    appimage.binfmt = true;

    firefox = {
      enable = true;
      languagePacks = [ "en-US" ];
      package = pkgs.firefox;
      preferences = {
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
        "browser.crashReports.unsubmittedCheck.enabled" = false;
        "browser.fixup.dns_first_for_single_words" =  false;
        "browser.newtab.extensionControlled" = true;
        "browser.search.update" = true;
        "browser.tabs.crashReporting.sendReport" = false;
        "browser.urlbar.suggest.bookmark" = false;
        "browser.urlbar.suggest.history" = true;
        "browser.urlbar.suggest.openpage" = false;
        "browser.tabs.warnOnClose" = false;
        "browser.urlbar.update2.engineAliasRefresh" = true;
        "datareporting.policy.dataSubmissionPolicyBypassNotification" = true;
        "dom.disable_window_flip" = true;
        "dom.disable_window_move_resize" = false;
        "dom.event.contextmenu.enabled" = true;
        "dom.reporting.crash.enabled" = false;
        "extensions.getAddons.showPane" = false;
        "media.gmp-gmpopenh264.enabled" = true;
        "media.gmp-widevinecdm.enabled" = true;
        "places.history.enabled" = true;
        "security.ssl.errorReporting.enabled" = false;
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };
      preferencesStatus = "default";
      policies = {
        "AutofillAddressEnabled" = false;
        "AutofillCreditCardEnabled" = false;
        "CaptivePortal" = true;
        "Cookies" = {
          "AcceptThirdParty" = "from-visited";
          "Behavior" = "reject-tracker";
          "BehaviorPrivateBrowsing" = "reject-tracker";
          "RejectTracker" = true;
        };
        "DisableAppUpdate" = true;
        "DisableDefaultBrowserAgent" = true;
        "DisableFirefoxStudies" = true;
        "DisableFormHistory" = true;
        "DisablePocket" = true;
        "DisableProfileImport" = true;
        "DisableTelemetry" = true;
        "DisableSetDesktopBackground" = true;
        "DisplayBookmarksToolbar" = "never";
        "DisplayMenuBar" = "default-off";
        "DNSOverHTTPS" = {
          "Enabled" = false;
        };
        "DontCheckDefaultBrowser" = true;
        "EnableTrackingProtection" = {
          "Value" = false;
          "Locked" = false;
          "Cryptomining" = true;
          "EmailTracking" = true;
          "Fingerprinting" = true;
        };
        "EncryptedMediaExtensions" = {
          "Enabled" = true;
          "Locked" = true;
        };
        # Check about:support for extension/add-on ID strings.
        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          "gdpr@cavi.au.dk" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/consent-o-matic/latest.xpi";
            installation_mode = "force_installed";
          };
          "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
            installation_mode = "force_installed";
          };
          "enterprise-policy-generator@agenedia.com" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/enterprise-policy-generator/latest.xpi";
            installation_mode = "force_installed";
          };
        };
        "ExtensionUpdate" = true;
        "FirefoxHome" = {
          "Search" = true ;
          "TopSites" = false;
          "SponsoredTopSites" = false;
          "Highlights" = false;
          "Pocket" = false;
          "SponsoredPocket" = false;
          "Snippets" = false;
          "Locked" = true;
        };
        "FirefoxSuggest" = {
          "WebSuggestions" = false;
          "SponsoredSuggestions" = false;
          "ImproveSuggest" = false;
          "Locked" = true;
        };
        "FlashPlugin" = {
          "Default" = false;
        };
        "HardwareAcceleration" = true;
        "NetworkPrediction" = false;
        "NewTabPage" = true;
        "NoDefaultBookmarks" = true;
        "OfferToSaveLogins" = false;
        "OverrideFirstRunPage" = "";
        "OverridePostUpdatePage" = "";
        "PasswordManagerEnabled" = false;
        "PopupBlocking" = {
          "Default" = true;
        };
        "PromptForDownloadLocation" = false;
        "SearchBar" = "unified";
        "SearchEngines" = {
          "Add" = [
            {
              "Description" = "Kagi";
              "IconURL" = "https://assets.kagi.com/v2/apple-touch-icon.png";
              "Method" = "GET";
              "Name" = "Kagi";
              "SuggestURLTemplate" = "https://kagi.com/api/autosuggest?q={searchTerms}";
              "URLTemplate" = "https://kagi.com/search?q={searchTerms}";
            }
          ];
          "Default" = "Kagi";
          "DefaultPrivate" = "Kagi";
          "Remove" = [
            "Bing"
            "eBay"
            "Google"
          ];
        };
        "SearchSuggestEnabled" = true;
        "ShowHomeButton" = false;
        "StartDownloadsInTempDirectory" = true;
        "UserMessaging" = {
          "WhatsNew" = false;
          "ExtensionRecommendations" = true;
          "FeatureRecommendations" = false;
          "UrlbarInterventions" = false;
          "SkipOnboarding" = true;
          "MoreFromMozilla" = false;
          "Locked" = false;
        };
        "UseSystemPrintDialog" = true;
      };
    };
    steam = lib.mkIf (isGamestation) {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
    system-config-printer = lib.mkIf (isInstall) {
      enable = if (desktop == "mate") then true else false;
    };
  };

  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = isGamestation;
      jack.enable = false;
      pulse.enable = true;
      wireplumber = {
        enable = true;
        configPackages = lib.mkIf (isGamestation) [
          (pkgs.writeTextDir "share/wireplumber/main.lua.d/99-alsa-lowlatency.lua" ''
              alsa_monitor.rules = {
                {
                  matches = {{{ "node.name", "matches", "*_*put.*" }}};
                  apply_properties = {
                    ["audio.format"] = "S16LE",
                    ["audio.rate"] = 48000,
                    -- api.alsa.headroom: defaults to 0
                    ["api.alsa.headroom"] = 128,
                    -- api.alsa.period-num: defaults to 2
                    ["api.alsa.period-num"] = 2,
                    -- api.alsa.period-size: defaults to 1024, tweak by trial-and-error
                    ["api.alsa.period-size"] = 512,
                    -- api.alsa.disable-batch: USB audio interface typically use the batch mode
                    ["api.alsa.disable-batch"] = false,
                    ["resample.quality"] = 4,
                    ["resample.disable"] = false,
                    ["session.suspend-timeout-seconds"] = 0,
                  },
                },
              }
            '')
        ];
      };
      extraConfig.pipewire."92-low-latency" = lib.mkIf (isGamestation) {
        "context.properties" = {
          "default.clock.rate"          = 48000;
          "default.clock.quantum"       = 64;
          "default.clock.min-quantum"   = 64;
          "default.clock.max-quantum"   = 64;
        };
        "context.modules" = [{
          name = "libpipewire-module-rt";
          args = {
            "nice.level" = -11;
            "rt.prio" = 88;
          };
        }];
      };
      extraConfig.pipewire-pulse."92-low-latency" = lib.mkIf (isGamestation) {
        "pulse.properties" = {
          "pulse.default.format" = "S16";
          "pulse.fix.format" = "S16LE";
          "pulse.fix.rate" = "48000";
          "pulse.min.frag" = "64/48000";      # 1.3ms
          "pulse.min.req" = "64/48000";       # 1.3ms
          "pulse.default.frag" = "64/48000";  # 1.3ms
          "pulse.default.req" = "64/48000";   # 1.3ms
          "pulse.max.req" = "64/48000";       # 1.3ms
          "pulse.min.quantum" = "64/48000";   # 1.3ms
          "pulse.max.quantum" = "64/48000";   # 1.3ms
        };
        "stream.properties" = {
          "node.latency" = "64/48000";        # 1.3ms
          "resample.quality" = 4;
          "resample.disable" = false;
        };
      };
    };
    printing = lib.mkIf (isInstall) {
      enable = true;
      drivers = with pkgs; [ gutenprint hplip ];
    };
    system-config-printer.enable = isInstall;
    udev.extraRules = ''
      # Expose important timers the members of the audio group
      # Inspired by musnix: https://github.com/musnix/musnix/blob/master/modules/base.nix#L94
      KERNEL=="rtc0", GROUP="audio"
      KERNEL=="hpet", GROUP="audio"
      # Allow users in the audio group to change cpu dma latency
      DEVPATH=="/devices/virtual/misc/cpu_dma_latency", OWNER="root", GROUP="audio", MODE="0660"
    '';

    # Disable xterm
    xserver = {
      desktopManager.xterm.enable = false;
      displayManager.gdm.autoSuspend = false;
      excludePackages = [ pkgs.xterm ];
    };
  };

  security = {
    pam.loginLimits = [
      { domain = "@audio"; item = "memlock"; type = "-"   ; value = "unlimited"; }
      { domain = "@audio"; item = "rtprio" ; type = "-"   ; value = "99"       ; }
      { domain = "@audio"; item = "nofile" ; type = "soft"; value = "99999"    ; }
      { domain = "@audio"; item = "nofile" ; type = "hard"; value = "99999"    ; }
    ];
    rtkit.enable = true;
  };

  xdg.portal = {
    config = {
      common = {
        default = [
          "gtk"
        ];
      };
    };
    enable = true;
    xdgOpenUsePortal = true;
  };
}
