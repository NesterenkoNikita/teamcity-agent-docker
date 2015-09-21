#!/bin/sh
# Build lib container and push it to registry
./build.sh

docker tag -f paralect/teamcity-agent pestworks/teamcity-agent

#push updated image
docker push paralect/teamcity-agent:latest
