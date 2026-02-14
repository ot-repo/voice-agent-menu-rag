# local, development, test, staging ,production
export APP_ENV=test
export AUTH_ENABLE=0
export DATABASE_DISPLAY_QUERY=false
export DATABASE_URL='postgres://user:password@localhost:5432/dbname?sslmode=disable'
export DEBUG=false
export LOG_ENABLE=1
export PORT=8080
export REDIS_URL='redis://localhost:6379'

#go test ./test/... -cover
