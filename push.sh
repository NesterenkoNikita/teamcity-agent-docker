#!/bin/sh
# Build lib container and push it to registry
./build.sh

docker tag -f paralect/teamcity-agent paralect/teamcity-agent:latest

#push updated image
docker push paralect/teamcity-agent:latest
