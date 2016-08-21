# Jenkins 2 CD Pipeline demo

Demonstrates a Jenkins 2.0 Pipeline which builds, tests, and deploys a java spring boot web application. The application is deployed to multiple environments with manual triggers before deploying to production. There are unit tests, acceptance tests, and smoke tests. I feel this mirrors many production implementations found in the wild.

The build and test infrastructure is "on-prem" meaning running locally in docker containers, while the application is deployed to Pivotal's cloud infrastructure. I like keeping these separate, but there is no reason the entire environment could not be deployed on a single cloud provider if that is closer to what you would like to learn.

The pipeline is fully automated, but contains user interaction before deployments to production and test environments. This means you must have the Jenkins console open and manually click proceed when prompted to deploy. This is obviously configurable, but was a feature I wanted to ensure worked as this is a safety blanket for many.

The application itself is creatively called [sample-spring-cloud-svc-ci](https://github.com/iflowfor8hours/sample-spring-cloud-svc-ci). I recommend forking that repository and starting from there as it makes things easier if you want to experiment.

Much of this demo is based on work done by [Mark Alston](http://github.com/malston) and all credit where it is due. I wanted to cut down the scope and combine some topics for a different audience, so I chose to fork. Props to you though Mark, thanks!

## Prerequsites

* Docker and docker-engine installed
* A Cloud Foundry account with a username and password
* A Cloud Foundry organization with three "spaces" defined
  * development
  * test
  * production

## Getting Started

Edit the `config.xml` file with your Cloud Foundry credentials. This whole project can be done on their free trial tier, so don't be afraid to sign up for an account with Pivotal cloud.

## To Run this Demo

* Clone this project
  ```
  git clone https://github.com/iflowfor8hours/jenkins2-pipeline-demo
  cd jenkins2-pipeline-demo
  ```

* Run the following commands to fetch and run the two Docker containers with Jenkins and Sonar locally.

  ```
  docker-compose up -d
  ```

* Go to http://$DOCKER_HOST:8080 (or http://localhost:8080) to check out your Jenkins interface and complete the set up by clicking the "Install suggested plugins" button.

* The default admin password will appear in the console as logs from Jenkins *if you look at them using `docker-compose logs`. This password is required to run through the initial setup of Jenkins. You can also retrieve the Jenkins Admin password by executing the following: `docker exec -it $(docker ps -l -q) cat /var/jenkins_home/secrets/initialAdminPassword` where ``docker ps -l -q`` will retrieve the last container ID. This is wrapped in the `getPass.sh` script, so simply executing `./getPass.sh` will return the Jenkins admin password.


* Create the demo pipeline job using the CLI:
  ```
  curl -O http://$JENKINS_URL:8080/jnlpJars/jenkins-cli.jar
  java -jar jenkins-cli.jar -s <REPLACE-WITH-JENKINS-URL> create-job sample-spring-cloud-svc-ci < config.xml --username admin --password <REPLACE-WITH-PASSWORD-ABOVE>
  ```

The above commands will create a job which will fetch the demo application from github and then build a pipeline based on the contents of the Jenkinsfile in that repository. I get an EOF error when I run that but the pipeline still gets uploaded to Jenkins.

* Run the pipeline and insert your cloud foundry credentials in Jenkins.

* Have a look at the results of your pipeline in the jenkins interface and the sonar results by going to [Sonar output](http://localhost:9000).

* Upon completion, your app will be hosted on Pivotal's cloud with a URL that you can find by going to the Routes section on the Pivotal Web Services interface. 


## To build the container locally

This project builds a custom Docker container with Jenkins plugins automatically installed, and the CF CLI automatically installed and configured so it can be used by Pipelines.

  `docker build -t iflowfor8hours/jenkins2-pipeline-demo .`

## To run the Jenkins container alone

```
  docker run -i -t -d -p 8080:8080 -p 50000:50000 --name=jenkins-pipeline-demo -v /var/jenkins_home iflowfor8hours/jenkins2-pipeline-demo
```

Once the startup sequence is completed, you can navigate to Jenkins using the `$JENKINS_URL`.


## Troubleshooting

To `docker exec` into a running instance and poke around:

  `docker exec -it $JENKINS_INSTANCE_ID /bin/bash`

To see the log output from the cluster, you can run the following command.

  `docker-compose logs`


## Explanation of Architecture

The intention of this being deployed on separate infrastructures is to simulate the common scenario of a clients desire to keep their build and test infrastructure onsite, but start to transition parts of their production or development infrastructure into cloud or PaaS offerings.

At the moment, my local machine is simulating the onsite environment. 

```
TODO:
[ ] Figure out persistence for the /var/jenkins_home directory using a data volume
[ ] Figure out why that EOF error when loading the pipeline initially
[ ] Skip the initial jenkins and bake the whole thing
```
