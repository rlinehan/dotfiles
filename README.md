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
