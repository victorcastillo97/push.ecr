.DEFAULT_GOAL := help

include makefiles/ct.mk
include makefiles/ecr.mk

OWNER          	= 568
TYPE_APP        ?= webapp
SERVICE_NAME    ?= tycho
ENV             = dev

REGION 			= us-west-2
PROJECT_NAME    		= ${OWNER}-${TYPE_APP}-${SERVICE_NAME}-${ENV}
IMAGE_PROJECT 			= ${PROJECT_NAME}:latest
AWS_PROFILE				= default

#Preview
deploy:
	@ make build.image && \
	make ecr.login && \
	make ecr.push.app