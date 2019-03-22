dotfiles
========

Repo for managing my dotfiles

# Vim plugins
Using git subtrees: http://blogs.atlassian.com/2013/05/alternatives-to-git-submodule-git-subtree/

This requires git 1.7.11+ to add plugins, but cloning and installing can be
done with previous versions of git.

  `git subtree add --prefix .vim/bundle/<plugin name> https://github.com/<author>/<plugin name>.git master --squash`

To update a plugin from the upstream repo

  `git subtree pull --prefix .vim/bundle/<plugin name> https://github.com/<author>/<plugin name>.git master --squash`

The gitconfig now includes aliases for adding and updating vim plugins:

   `git vimadd <author> <plugin name>` to add

   `git vimupdate <author> <plugin name>` to update

# Current vim plugins installed
* [scrooloose/nerdtree](https://github.com/scrooloose/nerdtree)
* [scrooloose/syntastic](https://github.com/scrooloose/syntastic)
* [altercation/vim-colors-solarized](https://github.com/altercation/vim-colors-solarized)
* [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive)
* [airblade/vim-gitgutter](https://github.com/airblade/vim-gitgutter)
* [godlygeek/tabular](https://github.com/godlygeek/tabular)
* [tpope/vim-endwise](https://github.com/tpope/vim-endwise)
* [rodjek/vim-puppet](https://github.com/rodjek/vim-puppet)
* [jtmkrueger/vim-c-cr](https://github.com/jtmkrueger/vim-c-cr)
* [bling/vim-bufferline](https://github.com/bling/vim-bufferline)
* [bling/vim-airline](https://github.com/bling/vim-airline)
* [vim-airline/vim-airline-themes](https://github.com/vim-airline/vim-airline-themes)
* [guns/vim-clojure-static](https://github.com/guns/vim-clojure-static)
* [kien/rainbow_parentheses.vim](https://github.com/kien/rainbow_parentheses.vim)
* [tpope/vim-fireplace](https://github.com/tpope/vim-fireplace)
* [vim-scripts/paredit.vim](https://github.com/vim-scripts/paredit.vim)
* [jratner/vim-flavored-markdown](https://github.com/jtratner/vim-flavored-markdown)
* [jpalardy/vim-slime](https://github.com/jpalardy/vim-slime)
* [itspriddle/vim-marked](https://github.com/itspriddle/vim-marked)
* [vim-latex/vim-latex](https://github.com/vim-latex/vim-latex)
* [jlanzarotta/bufexplorer](https://github.com/jlanzarotta/bufexplorer)
* [junegunn/fzf.vim](https://github.com/junegunn/fzf.vim)
* [tpope/vim-rhubarb](https://github.com/tpope/vim-rhubarb)
* [jremmen/vim-ripgrep](https://github.com/jremmen/vim-ripgrep)
