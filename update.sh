#!/bin/bash
set -eu

LVERSION=$(curl -sL "https://lidarr.servarr.com/v1/update/develop/changes?runtime=netcore&os=linuxmusl" | jq -r '.[0].version')

echo $(cat ../.token) | docker login ghcr.io -u $(cat ../.user) --password-stdin &>/dev/null

echo "Updating Lidarr: v$LVERSION"
docker build --quiet --force-rm --rm --tag ghcr.io/agpsn/docker-lidarr:develop --tag ghcr.io/agpsn/docker-lidarr:$LVERSION -f ./Dockerfile.develop .
git tag -f $LVERSION && git push --quiet origin $LVERSION -f --tags
git add . && git commit -m "Updated" && git push --quiet
docker push --quiet ghcr.io/agpsn/docker-lidarr:develop; docker push --quiet ghcr.io/agpsn/docker-lidarr:$LVERSION && docker image rm -f ghcr.io/agpsn/docker-lidarr:$LVERSION
echo ""

echo v$LVERSION > .version
