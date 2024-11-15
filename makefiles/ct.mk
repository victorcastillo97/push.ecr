
# Config Docker
PATH_DOCKERFILE 	= docker/app/docker/Dockerfile
PATH_CONTEXT_DOCKER = ./docker/app

build.image:
	@ docker build  \
		-f ${PATH_DOCKERFILE} \
		-t ${IMAGE_PROJECT} \
		${PATH_CONTEXT_DOCKER}