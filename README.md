# concourse-serverless-resource

Executes [Serverless](http://serverless.com) jobs


## Resource Configuration

* `repository`: *Required.* The name of the repository, e.g.
`marcelocorreia/concourse-serverless-resource`.


## Behavior

### `check`: Check for new images.

The current image digest is fetched from the registry for the given tag of the
repository.


### `out`: Executes serverless command.     

Executes serverless command as defined in the parameter **action**.


#### Parameters

* `job_dir`: *Required.* Location on the serverless job. 
**E.g.:** $GIT_REPO/lambda/hello
* `action`: *Required.* Serverless action command
	* deploy
	* info
	* metrics
	* remove
	* invoke
* `aws_secret_access_key`: *Required.* AWS Credential
* `aws_access_key_id`: *Required.* AWS Credential
* `handler`: *Optional.* Lambda handler function name

## Example

``` yaml
resource_types:
  - name: serverless-resource
    type: docker-image
    source:
      repository: marcelocorreia/concourse-serverless-resource
      tag: latest

resources:
  - name: serverless
    type: serverless-resource
    source:
      repository: serverless
      version: serverless
  
  - name: docker-repo
    type: git
    source:
      ...

jobs:
  - name: deploy
    build_logs_to_retain: 10
    serial: true
    plan:
      - get: docker-repo
        trigger: true
      - put: serverless
        params:
          job_dir: 'lambda/hello'
          action: deploy
          aws_access_key_id: {{aws_access_key_id}}
          aws_secret_access_key: {{aws_secret_access_key}}

  - name: remove
    build_logs_to_retain: 10
    serial: true
    plan:
      - get: docker-repo
        trigger: false
      - put: serverless
        params:
          job_dir: 'lambda/hello'
          action: remove
          aws_access_key_id: {{aws_access_key_id}}
          aws_secret_access_key: {{aws_secret_access_key}}

  - name: info
    build_logs_to_retain: 10
    serial: true
    plan:
      - get: docker-repo
        trigger: false
      - put: serverless
        params:
          job_dir: 'lambda/hello'
          action: info
          handler: hello
          aws_access_key_id: {{aws_access_key_id}}
          aws_secret_access_key: {{aws_secret_access_key}}

  - name: metrics
    build_logs_to_retain: 10
    serial: true
    plan:
      - get: docker-repo
        trigger: true
      - put: serverless
        params:
          job_dir: 'lambda/hello'
          action: metrics
          handler: hello
          aws_access_key_id: {{aws_access_key_id}}
          aws_secret_access_key: {{aws_secret_access_key}}

  - name: invoke
    build_logs_to_retain: 10
    serial: true
    plan:
      - get: docker-repo
        trigger: true
      - put: serverless
        params:
          job_dir: 'lambda/hello'
          action: invoke
          handler: hello
          aws_access_key_id: {{aws_access_key_id}}
          aws_secret_access_key: {{aws_secret_access_key}}
```

### Contributing

Please make all pull requests to the `master` branch and ensure tests pass
locally.

