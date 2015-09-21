#!/bin/sh
# Build lib container and push it to registry
./build.sh

sudo docker tag -f paralect/teamcity-agent pestworks/teamcity-agent

#push updated image
sudo docker push paralect/teamcity-agent:latest
