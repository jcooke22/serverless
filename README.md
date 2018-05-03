# Serverless

An example of a serverless pipeline, with a Python implementation.

This package provides a bootstraped project which can be deployed as-is, and will provision the following Amazon AWS services:

- Creates a new [S3 bucket](https://aws.amazon.com/s3/) to store your built code artifact
- A [CloudFormation](https://aws.amazon.com/cloudformation/) stack responsible for setting up the required infrastructure and permissions 
- An [API gateway](https://aws.amazon.com/api-gateway/) endpoint which exposes an `my-endpoint` GET endpoint that triggers the lambda
- A new Lambda function 

All you need to do, is provide the code that you wish to run and some basic credentials for your AWS account.

## Requirements

- An [AWS account](https://portal.aws.amazons.com/billing/signup#/start)
- [Python 3.6](https://www.python.org/) & [PIP package manager](https://pypi.org/project/pip/)
- [Node](https://nodejs.org/en/) / NPM
- [Docker](https://www.docker.com/)
- [AWS cli](https://aws.amazon.com/cli/)
- [AWS SAM cli](https://docs.aws.amazon.com/lambda/latest/dg/sam-cli-requirements.html)

## Installation

Firstly, ensure that you have Node installed on your machine. You may wish to install [Homebrew](https://brew.sh/) in order to manage packages easily. (All examples provided assume an OSX environment and will use Homebrew where possible)

**Install Homebrew package manager**
```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

**Install Node using Homebrew**
```bash
# Check if Node is already installed
node -v
# Install Node if it was not found using the previous command
brew install node
```

OSX has Python 2.7 install by default, but we'll need Python 3.6.

**Check if Python 3 is available**
```bash
# This will most likely output a version of 2.x
python --version

# Check if the python3 binary is available
python3 --version
```

**Install Python 3**
```bash
brew install python
```

This will also install PIP (the Python package manager). Depending on how Homebrew installed Python, it may be available via either the `python` or `python3` command. It's theoretically possible to symlink `python` to the `python3` binary, but the pros and cons of doing so are outside of the scope of this package.

**Install the [AWS cli tool](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)**
```bash
pip install awscli --upgrade --user
```

To use the AWS cli tool, you will need to [generate an access key and secret](https://aws.amazon.com/premiumsupport/knowledge-center/create-access-key/) for your AWS IAM user. Once you have these, let's configure the AWS tool:

```bash
aws configure
```

Provide the access key and other credentials, you can see a [full list of available regions](https://docs.aws.amazon.com/general/latest/gr/rande.html) via the [official documentation](https://docs.aws.amazon.com/general/latest/gr/rande.html). We'll use `eu-west-2` (London) and the `json` output type.

Next, test that the cli is configured and working correctly by trying to list all Lambda functions:

```bash
aws lambda list-functions
```

**Install the AWS SAM cli tool**
```bash
npm install -g aws-sam-local

# Verify that SAM was installed
sam --version
```

**Install [Docker](https://www.docker.com/)**

Visit the [Docker official download page](https://www.docker.com/community-edition#/download) and click on the relevant download link. Once downloaded simply follow the instructions in the installation tool.

**Verify that Docker is working**
```bash
docker --version
docker run hello-world
```

When developing locally, we'll be using the [official Amazon Docker Lambda image](https://github.com/lambci/docker-lambda). This is taken care of automatically via this package.


## Local development

This project takes the following structure (the most important files are listed):

```
/src
deploy.sh
env.json.example
install.sh
run.sh
template.yaml
```

Your application's source code should be contained within the `/src` directory. The [official Amazon convention](https://docs.aws.amazon.com/lambda/latest/dg/python-programming-model-handler-types.html) documents that Lambda functions are handled by a method called `handler` which accepts and `event` and a `context` argument.

`event` – AWS Lambda uses this parameter to pass in event data to the handler. This parameter is usually of the Python dict type. It can also be list, str, int, float, or NoneType type. This could be helpful to get the query parameters or post request object from the request.

`context` – AWS Lambda uses this parameter to provide runtime information to your handler. This parameter is of the LambdaContext type.

**Running your application locally - run.sh**

Using this package you are able to develop you application using your usual development technique (in a regular IDE, using packages, running unit tests, etc.).

To simulate how your application would respond within the Lambda environment, from the terminal you can run:

```bash
./run.sh
```

This will launch a Docker container using the official Amazon Lambda image, which simulates closely the same environment used in Lambda. This command will expose endpoints based on the configuration provided in `template.yaml` which you can access via your local browser.

When returning a response from a Lambda function, you must ensure that you return a response object which has a `body` and `statusCode` attribute. The provided example in `/src/lambda.py` should get you started.

**Defining endpoints and handlers - template.yaml**

The `template.yaml` file is a [`SAM` configuration document](https://docs.aws.amazon.com/lambda/latest/dg/serverless_app.html) which is used to define:

- Where your code lives - in this case, S3.
- How your Lambda function is triggered - in this case via an Api gateway endpoint.
- Security policies - for example, if your function needs to connect to an RDS database, you may need to supply the relevant IAM policies.
- Endpoint definition - this can be written inline, or using a [Swagger specification](https://editor.swagger.io/)
 
**Note: SAM uses a convention which looks for a `template.yaml` file so you should not rename this file.**

## Deploying

Open the `deploy.sh` file and provide the name of the S3 bucket where your code will be stored, and a unique application name.

**Trigger a new deployment**

```bash
./deploy.sh
```

That's it!

To find the endpoint through which your Lambda function is available, you will need to manually log into the AWS console to view the newly created Lambda function.

The format will by default follow:

https://**randomcharacters**.execute-api.**region-name**.amazonaws.com/Prod/**my-endpoint**

If a deployment fails, CloudFormation will keep the stack in a `ROLLBACK_COMPLETE` state to allow for manual debugging. You will need to log in via the [AWS console](https://eu-west-2.console.aws.amazon.com/cloudformation/home?region=eu-west-2#/stacks?filter=active) to manually clear the failed stack. 

## Limitations of Lambda

- 50Mb maximum size of your codebase with dependencies (compressed) 
- 250Mb maximum size of decompressed code with dependencies
- The Lambda environment does not have any common dependencies installed, you need to ship a compiled version of any package you require (eg. Pandas, matplotlib, Selenium)
- Max execution time of a function 300 seconds (5 minutes)
- Maximum temp disk space 512Mb
- Invoke request maximum payload 6MB
- There’s a 1000 max concurrency limit of Lambdas

By far the biggest issue is that for Lambdas to remain fast, and respond within milliseconds, you cannot have a build process to install dependencies as we'd traditionally do in a server-based architecture. This means that all dependencies must be packaged with your codebase and when deployed to S3, cannot exceed 50Mb. 

More limitations are also available via the official [AWS documentation](https://docs.aws.amazon.com/lambda/latest/dg/limits.html).

## Advanced topics

### Generate an example event

Events are how we trigger Lambda functions. Here, we'll generate an event which triggers on a `GET` request to the `example` api-gateway endpoint:

```bash
sam local generate-event api --method GET --path example
```

This can be particularly helpful when your Lambda function is not invoked via an API gateway endpoint, but via an event queue.

### Environment variables and credentials

We should never store sensitive information or credentials in version control. A common way of getting around this is by shipping an environment example file, which we can edit in production directly with the values expected.

Lambda allows us to edit the environment variables required by our application via its online interface.

To use environment variables when developing locally, copy the example environment file provided:

```bash
cp env.json.example env.json
```

Open the `env.json` file and supply the required values. 

**Note: the `env.json` file must **not** be committed to version control, as it will contain sensitive information (e.g. credentials).**
