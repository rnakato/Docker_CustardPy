for tag in 0.3.0 #0.3.0
do
    docker build -f Dockerfile.$tag -t rnakato/custardpy:$tag . #--no-cache
    docker push rnakato/custardpy:$tag
    docker build -f Dockerfile.$tag -t rnakato/custardpy .
    docker push rnakato/custardpy
done
