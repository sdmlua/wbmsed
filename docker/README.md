# WBMsed Docker

The `Dockerfile` is based off of CentOS 7. It can be pulled using: 

``` bash
docker pull aaraney/wbmsed
```

WBMsed is precompiled in the image and sits at
`/wbmsed/Model/WBMplus/bin/wbmplus.bin`. The default entrypoint is
/wbmsed.

## Usage

1. Ensure that the docker daemon is running.
1. Run `docker-compose run --rm wbmsed` to start the container. It
   will start an interactive `bash` shell. The folder containing
`docker-compose.yml` will be mounted to the container at
`/wbmsed/domain`, however the entrypoint is `/wbmsed` and the model
executable is at `/wbmsed/Model/WBMplus/bin/wbmplus.bin`.

## Useful information
- centOS uses the `yum` package manager. You can install things once
  the container has spun up using `yum install <package-name> ...`.
