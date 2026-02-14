include .env
export $(shell sed 's/=.*//' .env)

start:
	@go run cmd/api.go
lint:
	@golangci-lint run
tests:
	@go test -v ./test/...
tests-%:
	@go test -v ./test/... -run=$(shell echo $* | sed 's/_/./g')
testsum:
	@cd test && gotestsum --format testname
migration-%:
	@goose create -ext sql -dir src/database/migrations create-table-$(subst :,_,$*)
migrate-up:
	@goose postgres ${DATABASE_URL} -dir ./databases/postgres/migrations up
migrate-down:
	@goose postgres ${DATABASE_URL} -dir ./databases/postgres/migrations reset
migrate-docker-up:
	@docker run -v ./src/database/migrations:/migrations --network go-fiber-boilerplate_go-network migrate/migrate -path=/migrations/ -database ${DATABASE_URL} up
migrate-docker-down:
	@docker run -v ./src/database/migrations:/migrations --network go-fiber-boilerplate_go-network migrate/migrate -path=/migrations/ -database ${DATABASE_URL} down -all
docker-cache:
	@docker builder prune -f