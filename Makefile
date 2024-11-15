AWS_REGION = eu-west-1
ACCOUNT_ID = 009160057631

DB_INIT_REPO = db-init-repo
DB_INIT_LAMBDA_PATH = db-init-lambda

ecr_login:
	@echo "Authenticating Docker to ECR..."
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com

push_db_init_lambda: ecr_login
	@echo "Building Docker image for db-init-repo..."
	docker build -t $(DB_INIT_REPO) $(DB_INIT_LAMBDA_PATH)
	@echo "Tagging Docker image..."
	docker tag $(DB_INIT_REPO):latest $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(DB_INIT_REPO):latest
	@echo "Pushing Docker image to ECR..."
	docker push $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(DB_INIT_REPO):latest

# Build and push all images
push_all: push_db_init_lambda

.PHONY: ecr_login push_db_init_lambda push_all
