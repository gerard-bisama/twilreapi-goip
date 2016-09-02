# Twireapi /twi-reap-i/ (Twilio Rest API)

[![Build Status](https://travis-ci.org/dwilkie/twilreapi.svg?branch=master)](https://travis-ci.org/dwilkie/twilreapi)

Twireapi is an Open Source implementation of [Twilio's REST API](https://www.twilio.com/docs/api/rest) written in Rails. You can use Twireapi as a drop-in replacement for Twilio and enqueue calls, send SMS etc.

## Installation

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Note check the output of `bin/setup` and note down the Account SID and Auth Token. To reseed the database run `bin/rails db:seed`

## Usage

### Configuration

Configuration is done using environment variables. See [.env](https://github.com/dwilkie/twilreapi/blob/master/.env)

### Running Locally

Start the web server using foreman. Note this will read the environment variables from [.env](https://github.com/dwilkie/twilreapi/blob/master/.env)

```
$ bundle exec foreman start web
```

### Background Processing

Twilreapi is queue agnostic. By default it will enqueue jobs using ActiveJob. The following background processing libraries are also supported and can be configured using [environment variables.](https://github.com/dwilkie/twilreapi/blob/master/.env)

* [active-elastic-job](https://github.com/tawan/active-elastic-job) (Default. Recommended for AWS deployment)
* [twilreapi-sidekiq](https://github.com/dwilkie/twilreapi-sidekiq) (Recommended for Heroku deployment)
* [shoryuken](https://github.com/phstc/shoryuken)

### Outbound Calls

In order to trigger outbound calls you can connect Twilreapi to [Somleng](https://github.com/dwilkie/somleng).

## Deployment

### Heroku

For testing we recommend deploying to Heroku. In order for Twilreapi to run on Heroku you need to configure [twilreapi-sidekiq](https://github.com/dwilkie/twilreapi-sidekiq) to handle the background processing. In the [Gemfile](https://github.com/tawan/active-elastic-job/blob/master/Gemfile) ensure that Sidekiq is installed, then use the Deploy button below. See [twilreapi-sidekiq](https://github.com/dwilkie/twilreapi-sidekiq) for more info on how to process jobs and connect to [Somleng](https://github.com/dwilkie/somleng) for outbound calls.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

After deployment seed the database to generate an `Account SID` and `Auth Token` and note down the values.

```
  $ heroku run rake db:seed
```

You can seed the database multiple times without generating multiple accounts.

### Elastic Beanstalk

#### Set up a VPC

1. Allocate an elastic IP address which will be used for your NAT gateway for your private subnet.
2. Create a new VPC using the wizard with a public and private subnet. Assign the elastic IP that you created above for the NAT Gateway.
3. Add an additional public and private subnet in a different availability zone. (In total you should have 4 subnets in your VPC. 1 private, and 1 public for each availability zone.
4. Connect both of your public subnets to the internet gateway, and both of your private subnets to the NAT Gateway.

#### Create a new web application environment

Launch a new web application environment using the ruby (Puma) platform. When prompted for the VPC, enter the VPC you created above. When prompted for EC2 subnets, enter the PUBLIC subnets (separated by a comma) for both availability zones. Enter the same for your ELB subnets.

```
$ eb create --vpc
```

##### Configure background queuing with SQS

In order to queue jobs to SQS, support for [active_elastic_job](https://github.com/tawan/active-elastic-job) is built in. Follow the [README](https://github.com/tawan/active-elastic-job). Set the SQS queue name in the ENV variable `ACTIVE_JOB_ACTIVE_ELASTIC_JOB_OUTBOUND_CALL_WORKER_QUEUE` in your web environment. The queue name will be generated when you create the worker environment. See below.

#### Create a new worker environment

Launch a new worker environment using the ruby (Puma) platform. When prompted for the VPC, enter the VPC you created above. When prompted for EC2 subnets, enter the PRIVATE subnets (separated by a comma for both availability zones). Enter the same for your ELB subnets (note there is no ELB for Worker environments so this setting will be ignored)


```
$ eb create --vpc --tier worker
```

##### Configure the queue

If you use the autogenerated queue for your worker environment then a dead-letter queue is automatically configured. This setting can be configured in the Elastic Beanstalk web console.

#### Deploy both the web and worker environments

```
$ eb deploy
```

#### Running rake tasks

```
$ cd /var/app/current
$ sudo su
$ bundle exec rake <task>
```

#### Connecting to RDS

Follow [this guide](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/AWSHowTo.RDS.html?icmpid=docs_elasticbeanstalk_console)

This needs to be done on both the web and worker environments.

#### SSH to the worker environment

Since the worker environment is on a private subnet, you can't reach it from the Internet. Instead ssh into your web environment and use ssh forwarding get to your worker instance.

```
$ eb ssh -e "ssh -A"
$ [ec2-user@private_ip_of_web_env ~]$ ssh <private_ip_of_worker_env>
```

## REST API Reference

### Calls

#### Make a Call

```
$ curl -XPOST https://your-host-name/api/2010-04-01/Accounts/{AccountSID}/Calls.json \
    -d "Url=http://demo.twilio.com/docs/voice.xml" \
    -d "To=%2B85512345678" \
    -d "From=%2B85512345679" \
    -u 'your_account_sid:your_auth_token'
```

#### Retrieve a Call

```
$ curl https://your-app-name.herokuapp.com/api/2010-04-01/Accounts/{AccountSID}/Calls/{CallSID}.json \
    -u 'your_account_sid:your_auth_token'
```

## License

The software is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
