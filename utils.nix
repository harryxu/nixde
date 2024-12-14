{
  importIfExists = path:
    if builtins.pathExists path
    then [ (import path) ]
    else [ ];
}
