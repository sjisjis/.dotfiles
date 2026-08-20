#!/usr/bin/env bash

[[ -e ~/.dotfiles ]] || git clone git@github.com:sjisjis/.dotfiles.git ~/.dotfiles
pushd ~/.dotfiles

if [ `uname` = "Darwin" ]; then
    brew bundle --file .Brewfile


  for i in `ls -a`
  do
      [ $i = "." ] && continue
      [ $i = ".." ] && continue
      [ $i = ".git" ] && continue
      [ $i = "README.md" ] && continue
      echo $i
      if [ $i = ".gitignore" ]; then
          ln -snfv ~/.dotfiles/$i ~/.config/git/ignore
      elif [ $i = "vscode" ]; then
          ln -snfv ~/.dotfiles/vscode/settings.json ~/Library/Application\ Support/Code/User/
          ln -snfv ~/.dotfiles/vscode/keybindings.json ~/Library/Application\ Support/Code/User/
      elif [ $i = ".claude" ]; then
          mkdir -p ~/.claude
          ln -snfv ~/.dotfiles/.claude/settings.json ~/.claude/settings.json
          ln -snfv ~/.dotfiles/.claude/statusline-command.sh ~/.claude/statusline-command.sh
          ln -snfv ~/.dotfiles/.claude/CLAUDE.md ~/.claude/CLAUDE.md
          for d in agents commands skills hooks output-styles; do
              ln -snfv ~/.dotfiles/.claude/$d ~/.claude/$d
          done
          continue
      fi
      ln -snfv ~/.dotfiles/$i ~/
  done

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
fi

popd
