# Serverless

An example of a serverless pipeline

## Requirements

- Python 3.6 & PIP package manager
- Node / NPM
- Docker
- AWS cli
- AWS SAM cli

## Generate an example event

Events are how we trigger Lambda functions. Here, we'll generate an event which triggers on a `GET` request to the `example` api-gateway endpoint:

```bash
sam local generate-event api --method GET --path example
```

## Set up environment variables

First, copy the example environment file provided:

```bash
cp env.json.example env.json
```

Open the `env.json` file and supply the required values. 

**Note: the `env.json` file should **not** be committed to version control, as it will contain sensitive information (e.g. credentials).**


## Deploying

You can trigger a new deployment using the following:

```bash
./deploy.sh
```

If a deployment fails, CloudFormation will keep the stack in a `ROLLBACK_COMPLETE` state to allow for manual debugging. You will need to log in via the [AWS console](https://eu-west-2.console.aws.amazon.com/cloudformation/home?region=eu-west-2#/stacks?filter=active) to manually clear the failed stack. 