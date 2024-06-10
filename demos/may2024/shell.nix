{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  # Additional tooling
  buildInputs = with pkgs; [
    kind
    kubernetes-helm
    kubectl
    k9s
    docker-client
  ];
}
