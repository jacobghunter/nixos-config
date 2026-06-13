{
  config,
  pkgs,
  inputs,
  ...
}:
{
programs.firefox = {
    enable = true;
    preferences = {
      "browser.startup.homepage"      = "https://duckduckgo.com";
      "privacy.resistFingerprinting"  = true;
    }
    userChrome = buildins.readFile ../../configs/firefox/userChrome.css;
    settings = {
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    }
  };
}