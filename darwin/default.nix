{
  pkgs,
  inputs,
  config,
  platform,
  hostname,
  username,
  lib,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    iina
  ];

  environment.variables = {
    EDITOR = "nvim";
    SYSTEMD_EDITOR = "nvim";
    VISUAL = "nvim";
  };

  nix = {
    package = pkgs.nix;
    gc.automatic = true;
    optimise.automatic = true;
    settings.experimental-features = "nix-command flakes";
  };

  system.primaryUser = "def4alt";

  networking.hostName = hostname;

  documentation.enable = true;
  documentation.man.enable = true;

  homebrew = {
    enable = true;
    brews = [
      "firebase-cli"
      "anomalyco/tap/opencode"
      "colima"
    ];
    casks = [
      "1password"
      "obsidian"
      "zen"
      "raycast"
      "rectangle"
      "signal"
      "zoom"
      "telegram"
      "calibre"
      "ghostty"
      "whatsapp"
      "anki"
      "topnotch"
      "tailscale-app"
      "visual-studio-code"
      "antigravity"
      "zotero"
      "minecraft"
    ];
    taps = [
      "anomalyco/tap"
    ];
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults = {
    dock.autohide = true;
    dock.persistent-apps = [
      "/Applications/Zen Browser.app"
      "/Applications/Ghostty.app"
    ];
    dock.largesize = 64;
    dock.magnification = true;
    dock.show-recents = false;
    dock.static-only = true;
    dock.tilesize = 16;
    dock.wvous-br-corner = 1;
    loginwindow.GuestEnabled = false;
    finder.AppleShowAllFiles = true;
    finder.AppleShowAllExtensions = true;
    finder.CreateDesktop = true;
    finder.FXEnableExtensionChangeWarning = false;
    finder.FXPreferredViewStyle = "clmv";
    finder.FXRemoveOldTrashItems = true;
    finder.NewWindowTarget = "Home";
    finder.ShowExternalHardDrivesOnDesktop = true;
    finder.ShowMountedServersOnDesktop = true;
    finder.ShowRemovableMediaOnDesktop = true;
    finder.ShowStatusBar = true;
    finder._FXShowPosixPathInTitle = true;
    finder._FXSortFoldersFirst = true;
    hitoolbox.AppleFnUsageType = "Change Input Source";
    NSGlobalDomain.AppleICUForce24HourTime = true;
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
    NSGlobalDomain.ApplePressAndHoldEnabled = false;
    NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
    NSGlobalDomain.NSAutomaticInlinePredictionEnabled = false;
    NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
    NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
    NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
    NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
    NSGlobalDomain.NSDisableAutomaticTermination = true;
    NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
    NSGlobalDomain.KeyRepeat = 5;
    NSGlobalDomain.InitialKeyRepeat = 10;
    NSGlobalDomain.AppleTemperatureUnit = "Celsius";
    NSGlobalDomain.AppleShowScrollBars = "WhenScrolling";
    NSGlobalDomain.AppleShowAllFiles = true;
    NSGlobalDomain.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleScrollerPagingBehavior = true;
    NSGlobalDomain.AppleMetricUnits = 1;
    NSGlobalDomain.AppleMeasurementUnits = "Centimeters";
    NSGlobalDomain.AppleFontSmoothing = 2;
    LaunchServices.LSQuarantine = false;
    ".GlobalPreferences"."com.apple.mouse.scaling" = 2.0;
    NSGlobalDomain.NSWindowResizeTime = 0.1;
    NSGlobalDomain._HIHideMenuBar = true;
    NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
    NSGlobalDomain."com.apple.swipescrolldirection" = false;
    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
    controlcenter.BatteryShowPercentage = false;
    controlcenter.Bluetooth = false;
    controlcenter.Display = false;
    controlcenter.FocusModes = false;
    controlcenter.NowPlaying = false;
    controlcenter.Sound = false;
    CustomUserPreferences = {
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          "60" = {
            # Disable '^ + Space' for selecting the previous input source
            enabled = false;
          };
          "61" = {
            # Disable '^ + Option + Space' for selecting the next input source
            enabled = false;
          };
          # Disable 'Cmd + Space' for Spotlight Search
          "64" = {
            enabled = false;
          };
          # Disable 'Cmd + Alt + Space' for Finder search window
          "65" = {
            # Set to false to disable
            enabled = true;
          };
        };
      };
    };
    menuExtraClock.Show24Hour = true;
    menuExtraClock.ShowDate = 1;
    menuExtraClock.ShowDayOfMonth = true;
    menuExtraClock.ShowDayOfWeek = false;
    menuExtraClock.ShowSeconds = true;
    trackpad.ActuationStrength = 0;
    trackpad.Clicking = true;
  };


  users.users.def4alt = {
    name = "${username}";
    home = "/Users/${username}";
  };

  environment.shells = [pkgs.zsh];
  environment.pathsToLink = [ "/share/zsh" ];

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  nixpkgs.hostPlatform = lib.mkDefault "${platform}";
}
