.PHONY: check_app_is_exist up

check_app_is_exist:
	mkdir -p $$PWD/app

build:
	docker-compose build

up: check_app_is_exist
	docker-compose up -d

dev: check_app_is_exist
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

force-recreate: check_app_is_exist
	docker-compose up -d --force-recreate

down:
	docker-compose down --remove-orphans -v