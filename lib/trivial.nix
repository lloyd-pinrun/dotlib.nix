lib: let
  trivial = {
    get = attrs: str: attrs.${str};
    pipe' = lib.flip lib.pipe;
    apply = arg: fun: fun arg;
    majorMinorVersion = trivial.pipe' [
      builtins.splitVersion
      (lib.sublist 0 2)
      (builtins.concatStringsSep ".")
      (builtins.replaceStrings ["."] [""])
    ];
    isNull = arg: arg == null;
    turnary = condition: yes: no:
      if condition
      then yes
      else no;
  };
in
  trivial
