{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "win2xcur";
  version = "0.1.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "quantum5";
    repo = "win2xcur";
    rev = "ea8366bc9d217e2f6112dac4dc50eac6d4386e90";
    hash = "sha256-ctT3zxvxrNbAwNvPvhLjV5RkhSG15LAYXm3+zZiEYUE=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    numpy
    wand
  ];

  pythonImportsCheck = [
    "win2xcur.main.win2xcur"
    "win2xcur.main.x2wincur"
    "win2xcur.main.win2xcurtheme"
    "win2xcur.main.inspectcur"
    "win2xcur.main.x2wincurtheme"
  ];

  meta = {
    description = "Tools that convert cursors between the Windows (*.cur, *.ani) and Xcursor format";
    homepage = "https://github.com/quantum5/win2xcur";
    changelog = "https://github.com/quantum5/win2xcur/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ teatwig ];
  };
}
