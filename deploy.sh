#!/bin/bash
docker login -e $DOCKER_EMAIL -u $DOCKER_USER -p $DOCKER_PASS
docker push giuliocalzo/ecs-demo-php-simple-app:v_$CIRCLE_BUILD_NUM
