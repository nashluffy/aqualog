SERVER_BINARY_NAME=./backend/cmd/server/

run:
	go run $(SERVER_BINARY_NAME)

.PHONY: gen

gen:
	@buf generate --include-imports --include-wkt

.PHONY: deps

deps:
	@echo "Ensuring all dependencies are installed..."
	@go install github.com/bufbuild/buf/cmd/buf@latest
	# Install Dart dependencies for gRPC
	@cd frontend && flutter pub add grpc protobuf
	@cd frontend && flutter pub get
	@curl -s --create-dirs -L -o bin/species.parquet https://fishbase.ropensci.org/fishbase/species.parquet
	@curl -s --create-dirs -L -o bin/comnames_all.parquet https://fishbase.ropensci.org/sealifebase/comnames_all.parquet

