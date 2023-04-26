tag=0.4.2
docker build -f Dockerfile.$tag -t rnakato/custardpy:$tag . #--no-cache
exit
docker push rnakato/custardpy:$tag
docker build -f Dockerfile.$tag -t rnakato/custardpy .
docker push rnakato/custardpy
