#!/bin/sh
# Build lib container and push it to registry
./build.sh

docker tag paralect/teamcity-agent paralect/teamcity-agent:1.0.0

#push updated image
docker push paralect/teamcity-agent:1.0.0
