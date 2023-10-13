# syntax=docker/dockerfile:1
FROM scratch as basebuild
ADD . /jannah-operator
WORKDIR /jannah-operator
CMD ["ls -lart"]