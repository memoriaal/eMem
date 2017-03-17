#!/bin/bash

docker build . -t emem
docker run --rm -p 9200:9200 emem
