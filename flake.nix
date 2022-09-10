{ 
  description = "Example Java Project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let 
        pkgs = nixpkgs.legacyPackages.${system};
        
        basePackages = with pkgs; [
          beam.packages.erlangR25.elixir_1_14
          beam.interpreters.erlangR25
        ];

        inputs = with pkgs; basePackages ++ lib.optionals stdenv.isLinux [ inotify-tools ]
          ++ lib.optionals stdenv.isDarwin
          (with darwin.apple_sdk.frameworks; [ CoreFoundation CoreServices ]);

        hooks = ''
          # this allows mix to work on the local directory
          mkdir -p .nix-mix .nix-hex
          export MIX_HOME=$PWD/.nix-mix
          export HEX_HOME=$PWD/.nix-mix
          export PATH=$MIX_HOME/bin:$MIX_HOME/escripts:$HEX_HOME/bin:$PATH
          # TODO: not sure how to make hex available without installing it afterwards.
          mix local.hex --if-missing
          export LANG=en_US.UTF-8
          export ERL_AFLAGS="-kernel shell_history enabled"
        '';
      in {
        devShell = pkgs.mkShell {
          buildInputs = inputs;
          shellHook = hooks;
        };
      });
}
