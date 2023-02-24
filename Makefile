SHELL=/bin/bash -euo pipefail

#Installs dependencies using poetry.
install-python:
	poetry install

#Installs dependencies using npm.
install-node:
	npm install --legacy-peer-deps

#Configures Git Hooks, which are scipts that run given a specified event.
.git/hooks/pre-commit:
	cp scripts/pre-commit .git/hooks/pre-commit

#Condensed Target to run all targets above.
install: install-node install-python .git/hooks/pre-commit

#Run the npm linting script (specified in package.json). Used to check the syntax and formatting of files.
lint:
	npm run lint
	find . -name '*.py' -not -path '**/.venv/*' | xargs poetry run flake8

#Removes build/ + dist/ directories
clean:
	rm -rf build
	rm -rf dist

#Creates the fully expanded OAS spec in json
publish:
	rm -rf build
	mkdir -p build
	npm run publish 2> /dev/null
	cp build/gp-connect-access-record-fhir.json PrismMockProvider/

#Runs build proxy script
build-proxy:
	scripts/build_proxy.sh

#Runs create KVM script
create-kvm:
	chmod +x scripts/create_kvm.sh
	scripts/create_kvm.sh

#Files to loop over in release
_dist_include="poetry.lock poetry.toml pyproject.toml Makefile build/. tests scripts endpoints terraform"

#Create /dist/ sub-directory and copy files into directory
release: clean publish build-proxy
	mkdir -p dist
	for f in $(_dist_include); do cp -r $$f dist; done
	cp ecs-proxies-deploy.yml dist/ecs-deploy-sandbox.yml
	cp ecs-proxies-deploy.yml dist/ecs-deploy-internal-qa-sandbox.yml
	cp ecs-proxies-deploy.yml dist/ecs-deploy-internal-dev-sandbox.yml

#################
# Test commands #
#################

TEST_CMD := @APIGEE_ACCESS_TOKEN=$(APIGEE_ACCESS_TOKEN) \
		poetry run pytest -v \
		--color=yes \
		--api-name=gp-connect-access-record-fhir \
		--proxy-name=$(PROXY_NAME) \
		-s

PROD_TEST_CMD := $(TEST_CMD) \
		--apigee-app-id=$(APIGEE_APP_ID) \
		--status-endpoint-api-key=$(STATUS_ENDPOINT_API_KEY)

#Command to run end-to-end smoktests post-deployment to verify the environment is working
smoketest:
	$(TEST_CMD) \
	--junitxml=smoketest-report.xml \
	-m smoketest

test:
	$(TEST_CMD) \
	--junitxml=test-report.xml \

smoketest-prod:
	$(PROD_TEST_CMD) \
	--junitxml=smoketest-report.xml \
	-m smoketest

test-prod:
	$(PROD_CMD) \
	--junitxml=test-report.xml \
