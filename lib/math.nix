_: let
  math = {
    pow = base: exp: builtins.foldl' (builtins.mul 1 (builtins.genList (_: base) exp));
  };
in
  math
