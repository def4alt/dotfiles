{
  hostname,
  lib,
  pkgs,
  platform,
  username,
  ...
}:
{
  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = lib.mkDefault platform;
  };

  nix = {
    gc.automatic = true;
    optimise.automatic = true;
    settings.experimental-features = "nix-command flakes";
  };

  networking.hostName = hostname;

  environment = {
    variables = {
      EDITOR = "nvim";
      SYSTEMD_EDITOR = "nvim";
      VISUAL = "nvim";
    };
    shells = [ pkgs.bashInteractive ];
    pathsToLink = [ "/share/bash-completion" ];
  };

  programs.bash.completion.enable = true;

  homebrew = {
    enable = true;
    enableBashIntegration = false;
    enableZshIntegration = false;
    casks = [
      "ghostty"
      "anki"
      "calibre"
      "topnotch"
      "minecraft"
      "zulu@8"
      "netnewswire"
      "epic-games"
      "jellyfin-media-player"
      "helium-browser"
      "tailscale"
      "1password"
      "whatsapp"
      "telegram"
      "orbstack"
    ];
    onActivation = {
      cleanup = "zap";
      autoUpdate = false;
      upgrade = false;
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    primaryUser = username;
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

    defaults = {
      dock = {
        autohide = true;
        largesize = 64;
        magnification = true;
        show-recents = false;
        tilesize = 58;
      };
      finder = {
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "clmv";
        FXRemoveOldTrashItems = true;
        NewWindowTarget = "Home";
        ShowMountedServersOnDesktop = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true;
        _FXSortFoldersFirst = true;
      };
      hitoolbox.AppleFnUsageType = "Change Input Source";
      NSGlobalDomain = {
        AppleFontSmoothing = 2;
        AppleICUForce24HourTime = true;
        AppleInterfaceStyle = "Dark";
        AppleMeasurementUnits = "Centimeters";
        AppleMetricUnits = 1;
        ApplePressAndHoldEnabled = false;
        AppleScrollerPagingBehavior = true;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        AppleTemperatureUnit = "Celsius";
        InitialKeyRepeat = 10;
        KeyRepeat = 5;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticInlinePredictionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSDisableAutomaticTermination = true;
        NSDocumentSaveNewDocumentsToCloud = false;
        NSWindowResizeTime = 0.1;
        _HIHideMenuBar = true;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.swipescrolldirection" = false;
      };
      LaunchServices.LSQuarantine = false;
      ".GlobalPreferences"."com.apple.mouse.scaling" = 2.0;
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      controlcenter = {
        BatteryShowPercentage = false;
        Bluetooth = false;
        Display = false;
        FocusModes = false;
        NowPlaying = false;
        Sound = false;
      };
      CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys = {
        # Disable Control-Space input-source shortcuts.
        "60".enabled = false;
        "61".enabled = false;
        # Disable Command-Space Spotlight search.
        "64".enabled = false;
      };
      menuExtraClock = {
        Show24Hour = true;
        ShowDate = 1;
        ShowDayOfMonth = true;
        ShowDayOfWeek = false;
        ShowSeconds = true;
      };
      trackpad = {
        ActuationStrength = 0;
        Clicking = true;
      };
    };

    # Used for backwards compatibility; consult `darwin-rebuild changelog` before changing.
    stateVersion = 5;
  };

  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.bashInteractive;
  };
}
