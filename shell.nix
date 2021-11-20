with import <nixpkgs> { };

let
  # define packages to install
  basePackages = [
    # replace with beam.packages.erlang.elixir_1_11 if you need
    beam.packages.erlang.elixir
  ];

  inputs = basePackages ++ lib.optionals stdenv.isLinux [ inotify-tools ]
    ++ lib.optionals stdenv.isDarwin
    (with darwin.apple_sdk.frameworks; [ CoreFoundation CoreServices ]);

  # define shell startup command
  hooks = ''
    # this allows mix to work on the local directory
    mkdir -p .nix-mix .nix-hex
    export MIX_HOME=$PWD/.nix-mix
    export HEX_HOME=$PWD/.nix-mix
    export PATH=$MIX_HOME/bin:$HEX_HOME/bin:$PATH
    # TODO: not sure how to make hex available without installing it afterwards.
    mix local.hex --if-missing
    export LANG=en_US.UTF-8
    export ERL_AFLAGS="-kernel shell_history enabled"
  '';

in mkShell {
  buildInputs = inputs;
  shellHook = hooks;
}

