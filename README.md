## vscode-tarball-updater

Updates Visual Studio Code tarball version if there's a newer version available than the one currently present on the system.

### Prerequisites
- set [appParentDir](https://github.com/lfir/vscode-tarball-updater/blob/main/vscode-tarball-updater.sh#L19C1)
variable with the absolute path of vscode app folder's parent directory
- wget
- vscode's current dir name == name of the dir that comes within the downloadable tarballs
(i.e. _VSCode-linux-x64_)
