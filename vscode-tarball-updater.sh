#!/bin/bash

compare() {
    vx=${1//./}
    vy=${2//./}
    
    if (( vx < vy )) ; then echo -1; fi
    if (( vx == vy )) ; then echo 0; fi
    if (( vx > vy )) ; then echo 1; fi
}


appParentDir="$HOME/Apps"
appDir='VSCode-linux-x64'
versFile="$appDir/resources/app/package.json"
currentVer=$(grep -Po '(?<="version": ")[0-9.]+' "$appParentDir"/$versFile)
latestVer=$(wget -O - 'https://github.com/microsoft/vscode/releases/latest' | grep -Po '(?<=tag/)[0-9.]+' | head -1)
cmp=$(compare "$latestVer" "$currentVer")

if (( cmp == 1 )) ; then
    wget -O - 'https://code.visualstudio.com/sha/download?build=stable&os=linux-x64' | tar xzf -
    mv "$appParentDir/$appDir" ./old && mv "$appDir" "$appParentDir" && rm -r ./old
fi
