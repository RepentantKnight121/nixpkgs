{ stdenv,
  fetchurl,
  lib,
  autoPatchelfHook,
  dpkg,
  patchelf,
  alsa-lib,
  cairo,
  cups,
  gtk3,
  mesa,
  nss,
  nspr,
  pango,
  libdrm,
  libgcrypt,
  libpulseaudio,
  libxkbcommon,
  libGL,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libXtst
}:

stdenv.mkDerivation rec {
  pname = "lark";
  version = "7.32.1";
  src = fetchurl {
    url = "https://sf16-va.larksuitecdn.com/obj/lark-artifact-storage/355bee5d/Lark-linux_x64-${version}.deb";
    sha256 = "sha256-DePiEOkaFJDobYABOpKVeoXF1xR6nq+M0jDh5cuj4pg=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    patchelf
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    alsa-lib
    cairo
    cups
    gtk3
    mesa # for libgbm
    nss
    nspr
    pango
    libdrm
    libgcrypt
    libpulseaudio
    libxkbcommon
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libXtst
    libGL
  ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack

    # The deb file contains a setuid binary, so 'dpkg -x' doesn't work here
    dpkg --fsys-tarfile $src | tar --extract

    runHook postUnpack
  '';

  # TODO: make binary work without throw segfault and error
  # by manually patchelf or something like that
  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/share opt $out

    mkdir -p $out/bin
    ln -s $out/opt/bytedance/lark/lark $out/bin/lark

    runHook postInstall
  '';

  # Use postFixup patchelf or makeWrapper to make it work no other way
  postFixup = ''
    makeWrapper --
    #patchelf $out/opt/bytedance/lark/lark \
    #  --add-rpath ${lib.makeLibraryPath [ libGL ]}
  '';

  meta = with lib; {
    homepage = "https://www.larksuite.com/en_sg";
    downloadPage = "https://www.larksuite.com/en_us/download";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ astronaut0212 ];
  };
}
