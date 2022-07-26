# Docker images for CustardPy

This repository contains the data to build two Docker images, **Docker_CustardPy** and **CustardPy_Juicer**, for [CustardPy](https://github.com/rnakato/CustardPy) analysis.
* **Docker_CustardPy** is a docker image for CustardPy analysis. 
* **CustardPy_Juicer** is a docker image for Juicer analysis in CustardPy. This is a wrapper of [Juicer](https://github.com/aidenlab/juicer/wiki) and internally executes juicertools. See the original website for the full description about each command.

See [CustardPy Manual](https://custardpy.readthedocs.io/en/latest/) for the detailed usage.

## Related links

- The Dockerfile of **CustardPy_Juicer** is based on [aidenlab/juicer](https://hub.docker.com/r/aidenlab/juicer).
- **CustardPy_Juicer** is the newer version of [docker_juicer](https://github.com/rnakato/docker_juicer).
- DockerHub: [Docker_CustardPy](https://hub.docker.com/r/rnakato/custardpy), [CustardPy_Juicer](https://hub.docker.com/r/rnakato/custardpy_juicer)

## Run

For Docker:

    # pull docker image
    docker pull rnakato/custardpy_juicer 

    # container login
    docker run [--gpus all] --rm -it rnakato/custardpy_juicer /bin/bash
    # execute a command
    docker run [--gpus all] --rm -v (your directory):/opt/work rnakato/custardpy_juicer <command>

For Singularity:

    # build image
    singularity build custardpy_juicer.sif docker://rnakato/custardpy_juicer
    # execute a command
    singularity exec [--nv] custardpy_juicer.sif <command>

## Build Docker image from Dockerfile
First clone and move to the repository

    git clone https://github.com/rnakato/CustardPy_Juicer.git
    cd CustardPy_Juicer

Then type:

    docker build -f Dokerfile.<version> -t <account>/custardpy_juicer .

## Contact

Ryuichiro Nakato: rnakato AT iqb.u-tokyo.ac.jp
