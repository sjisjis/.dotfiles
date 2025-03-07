#!/usr/bin/env bash

# vscode plugins
vspkglist=(
  eamodio.gitlens
  GitHub.codespaces
  GitHub.remotehub
  golang.go
  matklad.rust-analyzer
  ms-azuretools.vscode-docker
  MS-CEINTL.vscode-language-pack-ja
  ms-vsliveshare.vsliveshare
  rangav.vscode-thunder-client
  rust-lang.rust
  techer.open-in-browser
  vscodevim.vim
  wakatime.vscode-wakatime
)

for i in "${vspkglist[@]}"; do
  code --install-extension "$i"
done

echo "👍 VSCode setting is done!"

popd
