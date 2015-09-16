#!/bin/bash


function usage() {
    set -e
    cat <<EOM
    ##### build_docker_image #####
    Simple script for triggering Build on Docker Iamge

    Required arguments:
        -k | --docker-key              Name of service to deploy
        -i | --image                   Name of Docker image to run, ex: giuliocalzo/ecs-demo-php-simple-app

        Optional arguments:
            -t | --timeout          Default is 300s. Wait docker image .



EOM

    exit 2
}


VERBOSE=false
IMAGE=false
TIMEOUT=300

NOW=$(date +"%Y-%m-%d %T")

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
        -t|--timeout)
            TIMEOUT="$2"
            shift
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
    echo "[$NOW] DOCKER_KEY is required. You can set it as an environment variable or pass the value using -k or --docker-key"
    exit 1
fi

if [ $IMAGE == false ]; then
    echo "[$NOW] IMAGE is required. You can pass the value using -i or --image"
    exit 1
fi

RAW=$(curl -s  https://hub.docker.com/v2/repositories/$IMAGE/buildhistory/?page_size=1)
old_build_code=$( echo $RAW | jq .results[0].build_code)
trigger=true

if [ "$( echo $RAW | jq .results[0].status)" == 0 ]; then
  echo "[$NOW] IMAGE $old_build_code creation in progress"
  trigger=false
fi


if [ $trigger == true ]; then
  new_build_code="$old_build_code"
  # trigger build
  echo "[$NOW] trigger build to Hub Docker"
  curl -H "Content-Type: application/json" --data '{"build": true}' -X POST "https://registry.hub.docker.com/u/$IMAGE/trigger/$DOCKER_KEY/"
  echo ""
  # sleep 5

  # wait until build is ready
  while [ true  ]
  do
    new_build_code=$(curl -s  https://hub.docker.com/v2/repositories/$IMAGE/buildhistory/?page_size=1 | jq .results[0].build_code)
    echo "[$NOW] Wainting Docker Image Creation: old:$old_build_code  new:$new_build_code"
    if [ "$old_build_code" != "$new_build_code" ]; then
      break
    fi
    sleep 1
  done

fi


STATUS=$(curl -s  https://hub.docker.com/v2/repositories/$IMAGE/buildhistory/?page_size=1 | jq .results[0].status)

# See if the service is able to come up again
every=5
i=0
# wait until build is ready
while [ $i -lt $TIMEOUT ]
do
  NOW=$(date +"%Y-%m-%d %T")
  STATUS=$(curl -s  https://hub.docker.com/v2/repositories/$IMAGE/buildhistory/?page_size=1 | jq .results[0].status)
  echo "[$NOW] Waiting Docker Image... Code:$STATUS"

  if [[ $STATUS == 10 ]]; then
    echo "[$NOW] Build OK"
    exit 0
  fi

  if [[ $STATUS == -1 ]]; then
    echo "[$NOW] Build Error"
    exit 1
  fi

  sleep $every
  i=$(( $i + $every ))

done
