# syntax=docker/dockerfile:1
FROM {{ Jannah.stages.bootstrap.deploy.helm_values.images.pipeline.dockerfiles.alpine.from }}