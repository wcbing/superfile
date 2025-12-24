#!/usr/bin/env -S bash -euo pipefail

projectName="superfile"
version="v1.4.1-rc"
osList=("darwin" "linux" "windows")
archList=("amd64" "arm64")
mkdir dist

# Prevent macOS from adding ._* files to archives
export COPYFILE_DISABLE=1

for os in "${osList[@]}"; do
    for arch in "${archList[@]}"; do
        echo "$projectName-$os-$version-$arch"
        mkdir "./dist/$projectName-$os-$version-$arch"
        cd ../ || exit
        if [ "$os" = "windows" ]; then
            env GOOS="$os" GOARCH="$arch" CGO_ENABLED=0 go build -o "./release/dist/$projectName-$os-$version-$arch/spf.exe" main.go
            cd ./release || exit
            zip -jr "./dist/$projectName-$os-$version-$arch.zip" "./dist/$projectName-$os-$version-$arch"
        else
            env GOOS="$os" GOARCH="$arch" CGO_ENABLED=0 go build -o "./release/dist/$projectName-$os-$version-$arch/spf" main.go
            cd ./release || exit
            tar czf "./dist/$projectName-$os-$version-$arch.tar.gz" -C "./dist/$projectName-$os-$version-$arch" .
        fi
    done
done