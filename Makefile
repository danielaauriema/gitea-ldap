ifndef CMD
	CMD=/opt/test/test.sh
endif

IMG_TAG=auriema/gitea:test
V_TEST=-v "$(PWD)/test:/opt/test"
V_STARTUP=-v "$(PWD)/startup:/opt/startup"
DOCKER_PARAMS=--env-file .env \
	--name gitea_test \
	--network gitea_test

DOCKER_DOWN=docker compose down --remove-orphans

.PHONI: builf config test run up down

build:
	@docker build --no-cache -t $(IMG_TAG) .

config: up
	@docker run -it --rm \
	$(V_STARTUP) \
	$(DOCKER_PARAMS) \
	$(IMG_TAG) "/opt/startup/config.sh"
	@$(DOCKER_DOWN)

test: up
	@docker run -d --rm \
	$(V_TEST) \
	$(V_STARTUP) \
	$(DOCKER_PARAMS) \
	$(IMG_TAG)

	@docker exec -it gitea_test /bin/bash -c '$(CMD)'

	$(MAKE) down

ci-test: up
	@docker run -d --rm \
	$(V_TEST) \
	$(DOCKER_PARAMS) \
	$(IMG_TAG)

	@docker exec gitea_test /bin/bash -c '$(CMD)'

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
