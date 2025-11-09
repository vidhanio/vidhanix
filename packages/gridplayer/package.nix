{
  lib,
  python3,
  fetchFromGitHub,
  qt5,
  libxml2_13,
  fetchzip,
  fetchpatch,
  replaceVars,
  libvlc,
  streamlink,
}:
let
  python = python3.override {
    self = python;
    packageOverrides = final: prev: {
      lxml_5 =
        (prev.lxml.override {
          cython = final.cython_3_0;
          libxml2 = libxml2_13;
        }).overridePythonAttrs
          (old: rec {
            version = "5.4.0";

            src = old.src.override {
              tag = "lxml-${version}";
              hash = "sha256-yp0Sb/0Em3HX1XpDNFpmkvW/aXwffB4D1sDYEakwKeY=";
            };

            postPatch = null;
          });

      cython_3_0 = prev.cython.overridePythonAttrs (old: rec {
        version = "3.0.12";

        src = old.src.override {
          tag = version;
          hash = "sha256-clJXjQb6rVECirKRUGX0vD5a6LILzPwNo7+6KKYs2pI=";
        };
      });

      versioningit_2 = prev.versioningit.overridePythonAttrs (old: rec {
        version = "2.3.0";

        src = old.src.override {
          inherit version;
          hash = "sha256-HQ1xz6PCvE+N+z1KFcFE64qmoJ2dqYkj1BCZSi74Juo=";
        };
      });

      python-vlc = prev.python-vlc.overridePythonAttrs (old: {
        version = "3.0.11115";

        src = fetchzip {
          url = "https://files.pythonhosted.org/packages/fd/2d/f5ab9a8fb34db780364b980bfac6dd2fa750ecd7c9c299a8b728f924262c/python-vlc-3.0.11115.tar.gz";
          hash = "sha256-60YspQ9yQXao7XGZvXGkJmLlLC2B9mvAt7apqvssxs8=";
        };

        patches =
          let
            vlc-path = fetchpatch {
              url = "https://raw.githubusercontent.com/NixOS/nixpkgs/3398e66796b75e5cc4797a5bdcf84d79bf86c86f/pkgs/development/python-modules/python-vlc/vlc-paths.patch";
              hash = "sha256-/iC27ZOmrlGA86PH5zl4gXoMWz6MyN78zlhhVbtEPtM=";
            };
          in
          [
            (replaceVars vlc-path {
              libvlcPath = "${libvlc}/lib/libvlc.so.5";
            })
          ];

        postPatch = ''
          substituteInPlace vlc.py \
            --replace-fail 'getargspec' 'getfullargspec'
        '';
      });
    };
  };

  streamlink_6 = streamlink.overridePythonAttrs (old: rec {
    version = "6.2.1";

    src = old.src.override {
      inherit version;
      hash = "sha256-64Jmkva7L0oaik1UcCTQlUricL2us+O5CEc6pVsgnRI=";
    };

    build-system = with python.pkgs; [ setuptools ];

    nativeBuildInputs = with python.pkgs; [
      versioningit_2
    ];

    propagatedBuildInputs =
      (lib.remove python.pkgs.lxml old.propagatedBuildInputs)
      ++ (with python.pkgs; [
        lxml_5
        typing-extensions
      ]);

    nativeCheckInputs = [ ];

    patches = null;

    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace-fail 'backend-path = ["build_backend"]' '# backend-path = ["build_backend"]' \
        --replace-fail 'build-backend = "__init__"' '# build-backend = "__init__"'
    '';
  });
in
python.pkgs.buildPythonApplication rec {
  pname = "gridplayer";
  version = "0.5.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "vzhd1701";
    repo = "gridplayer";
    tag = "v${version}";
    hash = "sha256-HMPoVxtvvA22sO1JqKDjaP8GGeVF4CQJ8wLiULhs2uU=";
  };

  build-system = with python.pkgs; [ poetry-core ];

  nativeBuildInputs = [
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    qt5.qtbase
  ];

  dependencies = with python.pkgs; [
    pyqt5
    python-vlc
    yt-dlp
    pydantic_1
    streamlink_6
  ];

  pythonRemoveDeps = [
    "PyQt5-Qt5"
  ];

  pythonRelaxDeps = [
    "pyqt5"
    "yt-dlp"
  ];

  pythonImportsCheck = [ "gridplayer" ];

  nativeCheckInputs = with python.pkgs; [
    pytestCheckHook
  ];

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  meta = {
    description = "Play videos side-by-side";
    homepage = "https://github.com/vzhd1701/gridplayer";
    changelog = "https://github.com/vzhd1701/gridplayer/releases/tag/v${version}";
    license = with lib.licenses; [ gpl3Plus ];
    mainProgram = "gridplayer";
  };
}
