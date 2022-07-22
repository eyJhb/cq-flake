{ lib
, buildPythonPackage
, fetchFromGitHub
}:

buildPythonPackage rec {
  pname = "cq_warehouse";
  version = "0.6.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "gumyr";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-gCkDb2UmyHb+JEnonWkJr+oUkrntpclUMtHN9CBxleQ=";
  };

  preBuild = ''
    rm -rf dist
  '';

  meta = with lib; {
    description = " A cadquery parametric part collection";
    homepage = "https://cq-warehouse.readthedocs.io";
    license = licenses.asl20;
    maintainers = with maintainers; [ eyjhb ];
  };
}
