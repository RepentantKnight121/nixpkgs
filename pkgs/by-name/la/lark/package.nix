{ stdenv,
  fetchurl,
  lib,
  makeWrapper,
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
  version = "7.32.11";
  src = fetchurl {
    url = "https://sf16-va.larksuitecdn.com/obj/lark-artifact-storage/afc02e52/Lark-linux_x64-${version}.deb";
    sha256 = "sha256-hfLKbKzZzOYqNGEoLw4gMXI2jfNvtFPU7hAODeA9SxU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    patchelf
    makeWrapper
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

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/share opt $out

    mkdir -p $out/bin
    ln -s $out/opt/bytedance/lark/lark $out/bin/lark

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://www.larksuite.com/en_sg";
    downloadPage = "https://www.larksuite.com/en_us/download";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ astronaut0212 ];
  };
}
