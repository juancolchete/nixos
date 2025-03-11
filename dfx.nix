with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "dfx";
  src = fetchTarball {
    url = "https://github.com/dfinity/sdk/archive/refs/tags/0.25.0.tar.gz";
    sha256 = "1chd2r3xh230qmwf3747fay3msjhsxqa5ryny61iai4pnpgjj7xh";
  };
}
