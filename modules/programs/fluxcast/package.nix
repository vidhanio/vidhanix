let
  pkg =
    {
      lib,
      fetchFromGitHub,
      python3Packages,
      nix-update-script,
      xvfb-run,
      gobject-introspection,
      gtk3,

      ffmpeg,
      wf-recorder,
      pulseaudio,
      xrandr,
      iw,
      dnsmasq,
      gst_all_1,

      wfdSupport ? true,
      dlnaSupport ? true,
      castSupport ? true,
    }:
    python3Packages.buildPythonApplication rec {
      pname = "fluxcast";
      version = "0.2.2";

      src = fetchFromGitHub {
        owner = "IlyaP358";
        repo = "fluxcast";
        tag = "v${version}";
        hash = "sha256-VRzJPO5F+LAyNp9KtO1MC7nnqhHbOpN+p464waGTjAk=";
      };

      pyproject = true;

      build-system = with python3Packages; [
        hatchling
      ];

      dependencies = with python3Packages; [
        dbus-next
        pillow
        pychromecast
        pygobject3
        pystray
        upnpclient
      ];

      captureTools = [
        ffmpeg
        wf-recorder
        pulseaudio
        xrandr
      ];

      wfdTools = [
        iw
        dnsmasq
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
      ];

      makeWrapperArgs =
        let
          tools =
            lib.optionals (wfdSupport || dlnaSupport || castSupport) captureTools
            ++ lib.optionals wfdSupport wfdTools;
        in
        lib.optionals (tools != [ ]) [
          "--prefix"
          "PATH"
          ":"
          (lib.makeBinPath tools)
        ]
        ++ lib.optionals wfdSupport [
          # The wrapped gstreamer binaries only scan $NIX_PROFILES for
          # plugins; point them at the ones bundled in this closure.
          "--prefix"
          "GST_PLUGIN_SYSTEM_PATH_1_0"
          ":"
          (lib.makeSearchPath "lib/gstreamer-1.0" (
            with gst_all_1;
            [
              gst-plugins-base
              gst-plugins-good
              gst-plugins-bad
              gst-plugins-ugly
            ]
          ))
        ];

      nativeCheckInputs = [
        gobject-introspection
        gtk3
        xvfb-run
      ];

      # pystray's appindicator backend runs Gtk.init_check() at import time,
      # so the suite needs a display even though it never opens a window.
      checkPhase = ''
        runHook preCheck

        xvfb-run -s '-screen 0 1280x720x24' python -m unittest discover -s tests

        runHook postCheck
      '';

      pythonImportsCheck = [
        "main"
        "pypi_sysinstall"
      ];

      passthru.updateScript = nix-update-script {
        extraArgs = [ "--flake" ];
      };

      meta = {
        description = "Stream your Linux desktop to a Smart TV via Miracast/WFD, DLNA, or Chromecast";
        homepage = "https://github.com/IlyaP358/fluxcast";
        changelog = "https://github.com/IlyaP358/fluxcast/releases/tag/${src.tag}";
        license = lib.licenses.gpl3Plus;
        platforms = lib.platforms.linux;
        mainProgram = "fluxcast";
      };
    };
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.fluxcast = pkgs.callPackage pkg { };
    };
}
