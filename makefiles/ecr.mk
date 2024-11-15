STACK_TEMPLATES_PATH	= htps://s3.${BUCKET_INFRA_REGION}.amazonaws.com/${BUCKET_INFRA_STACK_PATH}
DEPLOY_REGION			= us-west-2

STACK_ECR_NAME 		= ecr-${PROJECT_NAME}
STACK_ECR_PATH		= ./cloudformation/stacks/ecr/repository.yml

ecr.create: #Create the ecr 
	@ aws cloudformation create-stack --stack-name ${STACK_ECR_NAME} \
	--template-body file://${STACK_ECR_PATH} \
	--parameters \
		ParameterKey=StackFilesPath,ParameterValue=${STACK_TEMPLATES_PATH} \
		ParameterKey=ProjectName,ParameterValue=${PROJECT_NAME} \
		--region ${DEPLOY_REGION}

	@ aws cloudformation wait stack-create-complete  \
	--stack-name ${STACK_ECR_NAME} --region ${DEPLOY_REGION}

ecr.update: # Update the ecr
	@ aws cloudformation update-stack --stack-name ${STACK_ECR_NAME} \
	--template-body file://${STACK_ECR_PATH} \
	--parameters \
		ParameterKey=StackFilesPath,ParameterValue=${STACK_TEMPLATES_PATH} \
		ParameterKey=ProjectName,ParameterValue=${PROJECT_NAME} \
		--region ${DEPLOY_REGION}

	@ aws cloudformation wait stack-update-complete \
	--stack-name ${STACK_ECR_NAME} --region ${DEPLOY_REGION}

ecr.delete:
	@ aws cloudformation delete-stack --stack-name ${STACK_ECR_NAME} --region ${DEPLOY_REGION}
	@ aws cloudformation wait stack-delete-complete --stack-name ${STACK_ECR_NAME} --region ${DEPLOY_REGION}

#Deploy image to ECR
ECR_REGION = ${DEPLOY_REGION}

envs:
	$(eval AWS_ACCOUNT_ID = $(shell aws sts get-caller-identity --query "Account" --output text))
	$(eval PATH_ECR = ${AWS_ACCOUNT_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com)

ecr.login: envs ## Login for the repository ECR in AWS.: make ecr.login
	@aws ecr get-login-password --region ${ECR_REGION} --profile ${AWS_PROFILE} | \
	docker login --username AWS --password-stdin \
	${PATH_ECR}

ecr.tag.image: envs ## Tag of image dockerized for the repository ECR.: make ecr.tag.image
	@docker tag ${IMAGE} ${PATH_ECR}/${IMAGE}

ecr.push: envs ## Allows to upload dockerized image to repository ECR.: make ecr.push
	@docker push ${PATH_ECR}/${IMAGE}

ecr.push.app: ## Create the ECR repository and host the image there for app.: make ecr.push.app
	@ make ecr.tag.image IMAGE=${IMAGE_PROJECT} && \
		make ecr.push IMAGE=${IMAGE_PROJECT}
