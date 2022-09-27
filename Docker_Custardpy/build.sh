for tag in 0.2.0 #0.1.0
do
    docker build -f Dockerfile.$tag -t rnakato/custardpy:$tag . #--no-cache
    docker push rnakato/custardpy:$tag
    docker build -f Dockerfile.$tag -t rnakato/custardpy .
    docker push rnakato/custardpy
done
