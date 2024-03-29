Hazard - A Technology Demo
===========

Searchable and visualized earthquake data.

Technologies
------------

* ElasticSearch
* NodeJS
* Docker
* Terraform
* Amazon Web Services (AWS)

Prerequisites
--------------

* Download and install Terraform https://www.terraform.io/downloads.html

  ```
  $ terraform -v
  Terraform v0.11.7
  ```
  
* Download and install Docker https://www.docker.com/community-edition

  ```
  $ docker -v
  Docker version 17.12.1-ce, build 7390fc6
  ```
  
* Download and install Docker Compose https://docs.docker.com/compose/install/#install-compose *(Only needed for Linux)*

  ```
  $ docker-compose -v
  docker-compose version 1.22.0, build f46880fe
  ```

* Download and install Node.js https://nodejs.org/en/download/

  ```
  $ node -v
  v8.11.3
  ```
  
  ```
  $ npm -v
  6.2.0
  ```

* Ensure vm.max_map_count >= 262144 https://www.elastic.co/guide/en/elasticsearch/reference/6.3/docker.html#docker-cli-run-prod-mode

  ```
  $ grep vm.max_map_count /etc/sysctl.conf
  vm.max_map_count=262144
  ```
  For a live system:
  ```
  sysctl -w vm.max_map_count=262144
  ```

* AWS CLI https://docs.aws.amazon.com/cli/latest/userguide/installing.html with credentials in `~/.aws/credentials`

  ```
  $ pip install awscli --upgrade --user
  $ aws --version
  aws-cli/1.15.71 Python/2.7.12 Linux/4.15.0-29-generic botocore/1.10.70

  $ aws configure
  AWS Access Key ID [None]: XXXXXXXXXXX
  AWS Secret Access Key [None]: XXXXXXXXXXXXXXX
  Default region name [None]: us-west-2
  Default output format [None]: json

  $ cat ~/.aws/credentials 
  [default]
  aws_access_key_id = XXXXXXXXXXXXX
  aws_secret_access_key = XXXXXXXXXXXXX

  $ cat ~/.aws/config 
  [default]
  output = json
  region = us-west-2
  ```



Running Locally
---------------

* ```docker-compose up```
* Open http://localhost:3000

Deploying to AWS
----------------

* TBD
