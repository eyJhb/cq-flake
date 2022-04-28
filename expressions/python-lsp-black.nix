{ lib
, buildPythonPackage
, fetchFromGitHub
, black
, toml
, pytestCheckHook
, python-lsp-server
, isPy3k
}:

buildPythonPackage rec {
  pname = "python-lsp-black";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "python-lsp";
    repo = "python-lsp-black";
    rev = "v${version}";
    sha256 = "sha256-0e1NTfF+fJvHvroWdX76sBuHo+Tl/oIWJ01yvj8ovvI=";
  };

  disabled = !isPy3k;

  doCheck = false;
  # checkInputs = [ pytestCheckHook ];

  propagatedBuildInputs = [ black toml python-lsp-server ];

  meta = with lib; {
    homepage = "https://github.com/python-lsp/python-lsp-black";
    description = "python-lsp-server plugin that adds support to black autoformatter, forked from https://github.com/rupert/pyls-black/";
    license = licenses.mit;
    maintainers = [ ];
  };
}
