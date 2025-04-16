{
  config,
  pkgs,
  rustToolchain,
  ...
}:

{
  home.packages = [
    # Use fenix to install the Rust toolchain
    (rustToolchain.stable.withComponents [
      "cargo"
      "clippy"
      "rustc"
      "rustfmt"
    ])
  ];
}
