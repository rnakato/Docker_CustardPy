reponame=custardpy_juicer

tag=0.1.0
docker build -f Dockerfile.$tag -t rnakato/$reponame:$tag .
docker push rnakato/$reponame:$tag

docker tag rnakato/$reponame:$tag rnakato/$reponame:latest
docker push rnakato/$reponame:latest
