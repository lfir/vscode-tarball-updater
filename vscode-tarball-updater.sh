#!/bin/bash

compare() {
    vx=${1//./}
    vy=${2//./}
    
    if (( vx < vy )) ; then echo -1; fi
    if (( vx == vy )) ; then echo 0; fi
    if (( vx > vy )) ; then echo 1; fi
}

cleanUpAndExitWithError() {
    cd - &>/dev/null
    rm -rf "$tmpdir"
    exit 1
}


appParentDir="$HOME/Applications"
appDir='VSCode-linux-x64'
versFile="$appDir/resources/app/package.json"
currentVer=$(grep -Po '(?<="version": ")[0-9.]+' "$appParentDir"/$versFile)
latestVer=$(wget -qO - 'https://github.com/microsoft/vscode/releases/latest' | grep -Po '(?<=tag/)[0-9.]+' | head -1)

if [[ -z "$currentVer" || -z "$latestVer" ]]; then
    echo 'Could not determine current or latest version. Aborting.'
    exit 1
fi

echo "Current installed version: $currentVer"
echo "Latest available version: $latestVer"

cmp=$(compare "$latestVer" "$currentVer")

if (( cmp == 1 )); then
    echo "Update available: $currentVer -> $latestVer. Performing replacement..."
    tmpdir=$(mktemp -d)
    cd "$tmpdir" || exit 1
    (wget -qO - 'https://code.visualstudio.com/sha/download?build=stable&os=linux-x64' | tar xzf -) || {
        echo 'Download or extract of new version failed. Aborting.'
        cleanUpAndExitWithError
    }

    if mv "$appParentDir/$appDir" old ; then
        if mv "$appDir" "$appParentDir" ; then
            cd - &>/dev/null
            rm -rf "$tmpdir"
            echo 'Replacement complete. Goodbye.'
        else
            echo 'Failed to move new version into place. Restoring backup...'
            mv old "$appParentDir/$appDir" || echo 'Restore failed.'
            cleanUpAndExitWithError
        fi
    else
        echo 'Failed to move existing app directory. Aborting.'
        cleanUpAndExitWithError
    fi
else
    if (( cmp == 0 )); then
        echo "No update needed: already at latest version ($currentVer)."
    else
        echo "Installed version ($currentVer) is newer than latest release ($latestVer). No action taken."
    fi
fi
