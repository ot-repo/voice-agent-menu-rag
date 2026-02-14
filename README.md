## Quick Start

Install the dependencies:

```bash
go mod tidy
```

Set the environment variables:

```bash
cp .env.example .env

# open .env and modify the environment variables (if needed)
```

To perform the migrations:
```bash
go install github.com/pressly/goose/v3/cmd/goose@latest
goose postgres $DATABASE_URL -dir ./databases/postgres/migrations/ up
#OR
#make migrate-up
```
## Commands

Running locally:

```bash
make start
```

Or running with live reload:

```bash
air
```

> [!NOTE]
> Make sure you have `Air` installed.\
> See 👉 [How to install Air](https://github.com/air-verse/air)

Testing:

```bash
# run all tests
make tests

# run all tests with gotestsum format
make testsum

# run test for the selected function name
make tests-TestUserModel
```

Docker:

```bash
# run docker container
make docker

# run all tests in a docker container
make docker-test
```