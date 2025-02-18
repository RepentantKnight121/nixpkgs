{ stdenv
, lib
, fetchFromGitHub
, autoreconfHook
, pkg-config
, openssl
, ppp
, systemd
, withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd
, withPpp ? stdenv.hostPlatform.isLinux
}:

stdenv.mkDerivation rec {
  pname = "openfortivpn";
  version = "1.22.1";

  src = fetchFromGitHub {
    owner = "adrienverge";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-FhS4q8p1Q2Lu7xj2ZkUbJcMWvRSn+lqFdYqBNYB3V1E=";
  };

  # we cannot write the config file to /etc and as we don't need the file, so drop it
  postPatch = ''
    substituteInPlace Makefile.am \
      --replace '$(DESTDIR)$(confdir)' /tmp
  '';

  nativeBuildInputs = [ autoreconfHook pkg-config ];

  buildInputs = [
    openssl
  ]
  ++ lib.optional withSystemd systemd
  ++ lib.optional withPpp ppp;

  configureFlags = [
    "--sysconfdir=/etc"
  ]
  ++ lib.optional withSystemd "--with-systemdsystemunitdir=${placeholder "out"}/lib/systemd/system"
  ++ lib.optional withPpp "--with-pppd=${ppp}/bin/pppd"
  # configure: error: cannot check for file existence when cross compiling
  ++ lib.optional (stdenv.hostPlatform != stdenv.buildPlatform) "--disable-proc";

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Client for PPP+SSL VPN tunnel services";
    homepage = "https://github.com/adrienverge/openfortivpn";
    license = licenses.gpl3;
    maintainers = with maintainers; [ madjar ];
    platforms = with platforms; linux ++ darwin;
    mainProgram = "openfortivpn";
  };
}
