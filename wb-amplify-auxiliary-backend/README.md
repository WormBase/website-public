WormBase Auxiliary Backends
===========================

A set of backend cloud resources managed largely by AWS Amplify.

These resources 
- are serverless (billed by usage instead of provisioning)
- are created with and interacted through the [AWS Amplify CLI](https://docs.amplify.aws/cli)
- can be replicated due to infrastructure as code


# Services

Multiple web services at WormBase are managed by AWS Amplify. A summary of the services are provided below.

## CeNGEN

The REST API for the CeNGEN expression chart in the Expression widget of a gene page.

The resources managed by Amplify includes an API Gateway, a Lambda function, and a Dynamodb table (storage):

| Category | Resource name                  |
| -------- | ------------------------------ |
| Storage  | cengen                         |
| Function | fetchCengenExpressionsByGeneId |
| Api      | cengenApi                      |

At the time of writing, these resources above are generate with the Amplify CLI without modification. One exceptinon is that the Lambda function is edited to remove PUT and POST handlers, since the database should not be modified.

### CeNGEN data flow

In addition to what is managed by Amplify, the backend for the CeNGEN expression chart also includes an ETL (extract, transform, load) pipeline managed by AWS Glue and object storage by AWS S3. Here is the data flow:

- The file provided by the CeNGEN group is uploaded to the `wormbase-cengen` S3 bucket under the path `/original`.
- The Glue crawler is run against the file to identify its schema and update the Data Catalog. This step has helped the creation of the Glue jobs below.
- The Glue job named `reformat-cengen` transforms the input file (such as renaming the columns) and deposit the output in the same S3 bucket under `/reformatted`. 
- The other Glue job named `import-cengen-to-dynamodb` loads the reformatted file into the DynamoDB table managed by Amplify. A job parameter with key `--AMPLIFY_ENV` specifies the amplify environment (such as "prod"), so that the data is written to the DynamoDB table associated with that environment.

_Permission for the Glue jobs are granted through the role `wormbase-cengen-glue-role`_.

If you intend to update the data, having some knowledge about AWS Glue would help. Here is a [brief intro to AWS Glue](https://www.youtube.com/watch?v=z3HeHlWg88M&t=5s). 


# Amplify Environments

An Amplify envorinment is a copy of the deployment. For development and testing, you might need to create a different environment before modifying the production environment.

Since a Amplify deployment is fully specified by the source code ("Infrastructure as code") in this directory, you can create a new environment from it.

To create a new environment, run

```
amplify env add
```

and follow the command line prompt.

Then, actually deploy the resources with

```
amplify push
```

More on the [Amplify Environment](https://docs.amplify.aws/cli/teams/overview).

More on command line options related to amplify environments, run `amplify env --help`.


# Resources
- Amplify documentation: https://docs.amplify.aws
- Amplify CLI documentation: https://docs.amplify.aws/cli
- More details on this folder & generated files: https://docs.amplify.aws/cli/reference/files
- Join Amplify's community: https://amplify.aws/community/