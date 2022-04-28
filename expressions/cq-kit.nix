{
  lib
  , buildPythonPackage
  , fetchFromGitHub
  , cadquery
  , pytestCheckHook
}:
buildPythonPackage rec {
  pname = "cq-kit";
  rev = "b7212f0cbdf4ce5353330cc96917088615bcb0dc";
  version = "git-" + builtins.substring 0 7 rev;
  src = fetchFromGitHub {
    owner = "michaelgale";
    repo = pname;
    inherit rev;
    sha256 = "sha256-AnvlmbOQrCLFRhndCnp6gTpmpA8w0X6Ze657W4BmAdo=";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = [ cadquery ];

  checkInputs = [ pytestCheckHook ];

  doCheck = false;
  preCheck = ''
    pushd .
    cd tests
  '';

  postCheck = ''
    popd
  '';

}
