#!/usr/bin/env bash


function usage() {
    set -e
    cat <<EOM
    ##### build_docker_image #####
    Simple script for triggering Build on Docker Iamge

    Required arguments:
        -k | --docker-key              Name of service to deploy
        -i | --image            Name of Docker image to run, ex: mariadb:latest

        giuliocalzo/ecs-demo-php-simple-app

EOM

    exit 2
}


VERBOSE=false
IMAGE=false
if [ -z ${DOCKER_KEY+x} ]; then DOCKER_KEY=false; fi

# Loop through arguments, two at a time for key and value
while [[ $# > 0 ]]
do
    key="$1"
    case $key in

      -i|--image)
          IMAGE="$2"
          shift
          ;;

      -k|--docker-key)
          DOCKER_KEY="$2"
          shift # past argument
          ;;

        -v|--verbose)
            VERBOSE=true
            ;;
        *)
            usage
            exit 2
        ;;
    esac
    shift # past argument or value
done

if [ $VERBOSE == true ]; then
    set -x
fi


if [ $DOCKER_KEY == false ]; then
    echo "DOCKER_KEY is required. You can set it as an environment variable or pass the value using -k or --docker-key"
    exit 1
fi

if [ $IMAGE == false ]; then
    echo "IMAGE is required. You can pass the value using -i or --image"
    exit 1
fi


# trigger build
curl -H "Content-Type: application/json" --data '{"build": true}' -X POST "https://registry.hub.docker.com/u/$IMAGE/trigger/$DOCKER_KEY/"
STATUS=0

# wait until build is ready
while [ $STATUS != 0 ]; do
  STATUS=$(curl -s  https://hub.docker.com/v2/repositories/$IMAGE/buildhistory/?page_size=1 | jq .results[0].status)
  sleep 1
  echo "Wainting Docker Image..."
done

  if [ $STATUS == 10 ]; then
    exit 0
  else
    exit 1
  fi
