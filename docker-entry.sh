#!/bin/bash
if [ -z "$TEAMCITY_SERVER" ]; then
    echo "TEAMCITY_SERVER variable not set, launch with -e TEAMCITY_SERVER=http://mybuildserver"
    exit 1
fi

if [ ! -d "$AGENT_DIR/bin" ]; then
    echo "$AGENT_DIR doesn't exist pulling build-agent from server $TEAMCITY_SERVER";
    let waiting=0
    until curl -s -f -I -X GET $TEAMCITY_SERVER/update/buildAgent.zip; do
        let waiting+=3
        sleep 3
        if [ $waiting -eq 120 ]; then
            echo "Teamcity server did not respond within 120 seconds"...
            exit 42
        fi
    done
    wget $TEAMCITY_SERVER/update/buildAgent.zip && unzip -d $AGENT_DIR buildAgent.zip && rm buildAgent.zip
    chmod +x $AGENT_DIR/bin/agent.sh
    echo "serverUrl=${TEAMCITY_SERVER}" > $AGENT_DIR/conf/buildAgent.properties
    echo "workDir=/data/work" >> $AGENT_DIR/conf/buildAgent.properties
    echo "tempDir=/data/temp" >> $AGENT_DIR/conf/buildAgent.properties
    echo "systemDir=../system" >> $AGENT_DIR/conf/buildAgent.properties

    if [ -n "$TEAMCITY_OWN_ADDRESS" ]; then
        echo "ownAddress=${TEAMCITY_OWN_ADDRESS}" >> $AGENT_DIR/conf/buildAgent.properties
    fi

    if [ -n "$TEAMCITY_OWN_PORT" ]; then
        echo "ownPort=${TEAMCITY_OWN_PORT}" >> $AGENT_DIR/conf/buildAgent.properties
    fi

    if [ -n "$TEAMCITY_AGENT_NAME" ]; then
        echo "name=${TEAMCITY_AGENT_NAME}" >> $AGENT_DIR/conf/buildAgent.properties
    fi
fi

echo "Starting buildagent..."
chown -R teamcity:teamcity /opt/buildAgent

wrapdocker gosu teamcity /opt/buildAgent/bin/agent.sh run
