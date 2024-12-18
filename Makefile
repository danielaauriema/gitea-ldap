ifdef CMD
	CMD_TEST=${CMD}
else
	CMD_TEST=/opt/test/test.sh
endif

IMG_TAG="auriema/gitea:test"
V_TEST="$(PWD)/test:/opt/test"
V_STARTUP="$(PWD)/startup:/opt/startup"
DOCKER_PARAMS=--env-file .env \
	--name gitea_test \
	--network gitea_test

DOCKER_DOWN=docker compose down --remove-orphans

.PHONI: builf config test run up down

build:
	@docker build --no-cache -t $(IMG_TAG) .

config: up
	@docker run -it --rm \
	-v "$(V_STARTUP)" \
	$(DOCKER_PARAMS) \
	$(IMG_TAG) "/opt/startup/config.sh"
	@$(DOCKER_DOWN)

test: up
	@docker stop gitea_test || true

	@docker run -d --rm \
	-v "$(V_TEST)" \
	-v "$(V_STARTUP)" \
	$(DOCKER_PARAMS) \
	$(IMG_TAG)

	@docker exec -it gitea_test /bin/bash -c '$(CMD_TEST)'

	@docker stop gitea_test
	@$(DOCKER_DOWN)

ci-test: up
	@docker stop gitea_test || true

	@docker run -d --rm \
	-v "${RUNNER_WORKSPACE}/gitea-ldap/startup:/opt/startup" \
	$(DOCKER_PARAMS) \
	$(IMG_TAG)

	@docker exec -it gitea_test /bin/bash -c '$(CMD_TEST)'

	@docker stop gitea_test
	@$(DOCKER_DOWN)

run: up
	@docker run -it --rm \
	-p "3000:3000" \
	-v "$(V_STARTUP)" \
	$(DOCKER_PARAMS) \
	$(IMG_TAG)
	@$(DOCKER_DOWN)

up:
	@docker compose up -d

down:
	@docker stop gitea_test || true
	@$(DOCKER_DOWN)
