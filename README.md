# concourse-serverless-resource

Executes [Serverless](http://serverless.com) jobs


## Resource Configuration

* `repository`: *Required.* The name of the repository, e.g.
`marcelocorreia/concourse-serverless-resource`.


## Behavior

### `check`: Check for new images.

The current image digest is fetched from the registry for the given tag of the
repository.


### `in`: Fetch the image from the registry.

TODO:

#### Parameters

* `save`: *Optional.* Place a `docker save`d image in the destination.
* `rootfs`: *Optional.* Place a `.tar` file of the image in the destination.
* `skip_download`: *Optional.* Skip `docker pull` of image. Artifacts based
  on the image will not be present.


### `out`: Executes serverless command.

Executes serverless command as defined in the parameter **action**. 
Actions Avaliable:
- deploy
- info
- metrics
- remove
- invoke


#### Parameters

* `build`: *Optional.* The path of a directory containing a `Dockerfile` to
  build.

* `load`: *Optional.* The path of a directory containing an image that was
  fetched using this same resource type with `save: true`.

* `dockerfile`: *Optional.* The path of the `Dockerfile` in the directory if
  it's not at the root of the directory.

* `cache`: *Optional.* Default `false`. When the `build` parameter is set,
  first pull `image:tag` from the Docker registry (so as to use cached
  intermediate images when building). This will cause the resource to fail
  if it is set to `true` and the image does not exist yet.
  
* `cache_tag`: *Optional.* Default `tag`. The specific tag to pull before
  building when `cache` parameter is set. Instead of pulling the same tag
  that's going to be built, this allows picking a different tag like
  `latest` or the previous version. This will cause the resource to fail
  if it is set to a tag that does not exist yet.

* `load_base`: *Optional.* A path to a directory containing an image to `docker
  load` before running `docker build`. The directory must have `image`,
  `image-id`, `repository`, and `tag` present, i.e. the tree produced by `/in`.

* `load_bases`: *Optional.* Same as `load_base`, but takes an array to load
  multiple images.

* `load_file`: *Optional.* A path to a file to `docker load` and then push.
  Requires `load_repository`.

* `load_repository`: *Optional.* The repository of the image loaded from `load_file`.

* `load_tag`: *Optional.* Default `latest`. The tag of image loaded from `load_file`

* `import_file`: *Optional.* A path to a file to `docker import` and then push.

* `pull_repository`: *Optional.* **DEPRECATED. Use `get` and `load` instead.** A
  path to a repository to pull down, and then push to this resource.

* `pull_tag`: *Optional.*  **DEPRECATED. Use `get` and `load` instead.** Default
  `latest`. The tag of the repository to pull down via `pull_repository`.

* `tag`: *Optional.* The value should be a path to a file containing the name
  of the tag.

* `tag_prefix`: *Optional.* If specified, the tag read from the file will be
  prepended with this string. This is useful for adding `v` in front of version
  numbers.

* `tag_as_latest`: *Optional.*  Default `false`. If true, the pushed image will
  be tagged as `latest` in addition to whatever other tag was specified.

* `build_args`: *Optional.*  A map of Docker build arguments.
  
  Example:

  ```yaml
  build_args:
    do_thing: true
    how_many_things: 2
    email: me@yopmail.com
  ```
    
* `build_args_file`: *Optional.* Path to a JSON file containing Docker build
  arguments.

  Example file contents:

    ```yaml
    { "email": "me@yopmail.com", "how_many_things": 1, "do_thing": false }
    ```            


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
      uri: {{git_repo_url}}
      branch: master
      private_key: {{git_private_key}}
      username: {{github_user}}      

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

## Development

### Prerequisites

* golang is *required* - version 1.9.x is tested; earlier versions may also
  work.
* docker is *required* - version 17.06.x is tested; earlier versions may also
  work.

### Running the tests

The tests have been embedded with the `Dockerfile`; ensuring that the testing
environment is consistent across any `docker` enabled platform. When the docker
image builds, the test are run inside the docker container, on failure they
will stop the build.

Build the image and run the tests with the following command:

```sh
docker build -t docker-image-resource .
```

To use the newly built image, push it to a docker registry that's accessible to
Concourse and configure your pipeline to use it:

```yaml
resource_types:
- name: docker-image-resource
  type: docker-image
  privileged: true
  source:
    repository: example.com:5000/docker-image-resource
    tag: latest

resources:
- name: some-image
  type: docker-image-resource
  ...
```

### Contributing

Please make all pull requests to the `master` branch and ensure tests pass
locally.

