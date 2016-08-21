#!/bin/bash
docker exec -it $(docker ps -l -q) cat /var/jenkins_home/secrets/initialAdminPassword
