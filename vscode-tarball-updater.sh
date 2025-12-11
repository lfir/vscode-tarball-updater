#!/usr/bin/env bash

# Echo 0 if versions are equal, -1 if left version is smaller than right one, 1 vice versa
compare() {
    if [[ "$1" == "$2" ]]; then
        echo 0
        return
    fi
    # Print each arg in a separate line and use sort for version comparison
    case $(printf '%s\n%s' "$1" "$2" | sort -V | head -1) in
        "$1") echo -1 ;;  # 1st argument is smaller
        "$2") echo 1  ;;  # 2nd argument is smaller
    esac
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
    echo 'Could not determine current or latest version. Aborting.' >&2
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
        echo 'Download or extract of new version failed. Aborting.' >&2
        cleanUpAndExitWithError
    }

    if mv "$appParentDir/$appDir" old ; then
        if mv "$appDir" "$appParentDir" ; then
            cd - &>/dev/null
            rm -rf "$tmpdir"
            echo 'Replacement complete. Goodbye.'
        else
            echo 'Failed to move new version into place. Restoring backup...' >&2
            mv old "$appParentDir/$appDir" || echo 'Restore failed.' >&2
            cleanUpAndExitWithError
        fi
    else
        echo 'Failed to move existing app directory. Aborting.' >&2
        cleanUpAndExitWithError
    fi
else
    if (( cmp == 0 )); then
        echo "No update needed: already at latest version ($currentVer)."
    else
        echo "Installed version ($currentVer) is newer than latest release ($latestVer). No action taken."
    fi
fi
