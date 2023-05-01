#!/bin/bash
set -eu

[ ! -d "/mnt/user/system/agpsn-github/lidarr-develop" ] && echo "No repo!" && exit 1
cd "/mnt/user/system/agpsn-github/lidarr-develop"

echo $(cat ~/.ghcr-token) | docker login ghcr.io -u $(cat ~/.ghcr-user) --password-stdin &>/dev/null

#GBRANCH=$(git branch | grep "*" | rev | cut -f1 -d" " | rev)
LVERSION=$(curl -sL "https://lidarr.servarr.com/v1/update/develop/changes?runtime=netcore&os=linuxmusl" | jq -r '.[0].version')

echo "Building and Pushing 'ghcr.io/agpsn/docker-lidarr:$LVERSION'"
docker build --quiet  --force-rm --rm --tag ghcr.io/agpsn/docker-lidarr:develop --tag ghcr.io/agpsn/docker-lidarr:$LVERSION -f ./Dockerfile.develop .
docker push --quiet ghcr.io/agpsn/docker-lidarr:develop; docker push --quiet ghcr.io/agpsn/docker-lidarr:$LVERSION && docker image rm -f ghcr.io/agpsn/docker-lidarr:$LVERSION
git tag -f $LVERSION && git push --quiet origin $LVERSION -f --tags
git add . && git commit -m "Updated" && git push --quiet
