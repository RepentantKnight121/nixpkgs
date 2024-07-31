{ stdenv, fetchFromGitHub, ... }:

stdenv.mkDerivation rec {
  pname = "catapult";
  version = "24.07a";

  src = fetchFromGitHub {
    owner = "qrrk";
    repo = "Catapult";
    rev = "${version}";
    sha256 = "sha256-sM2/0s5OiSpDXdJpdftAWdykIt3FkQHUNdzWxj2EdxQ=";
  };
}
