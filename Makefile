PROTO_SRC := protos
GO_OUT := gen/go
DART_OUT := frontend/lib/gen/dart

PROTOC_VERSION := 24.4
PROTOC_BASE_URL := https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTOC_VERSION)
PROTO_FILES := $(shell find $(PROTO_SRC) -name "*.proto")
# Add your Go and Dart plugin paths
PROTOC_GEN_GO=$(shell which protoc-gen-go)
PROTOC_GEN_GRPC=$(shell which protoc-gen-go-grpc)
PROTOC_GEN_DART=$(shell which protoc-gen-dart)
PROTOC_GEN_GRPC_WEB=$(shell which protoc-gen-grpc-web)

PROTOBUF_REPO := ./gen/protobuf
$(PROTOBUF_REPO):
	git clone --depth 1 https://github.com/protocolbuffers/protobuf.git $(PROTOBUF_REPO)
PROTO_INCLUDE := $(PROTOBUF_REPO)/src


GO_TOOLS := \
	google.golang.org/protobuf/cmd/protoc-gen-go@latest \
	google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest


SERVER_BINARY_NAME=backend/cmd/server/main.go

run:
	go run $(SERVER_BINARY_NAME)

.PHONY: gen

gen: $(PROTOBUF_REPO)
	@mkdir -p $(GO_OUT) $(DART_OUT)
	@for file in $(PROTO_FILES); do \
		protoc -I$(PROTO_SRC) \
			-I$(PROTO_INCLUDE) \
			--go_out=$(GO_OUT) --go_opt=paths=source_relative \
			--go-grpc_out=$(GO_OUT) --go-grpc_opt=paths=source_relative \
			--dart_out=grpc:$(DART_OUT) \
			$$file; \
	done

.PHONY: deps

deps:
	@echo "Ensuring all dependencies are installed..."
	# Install Go dependencies
	@go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	@go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	@go install github.com/bufbuild/buf/cmd/buf@latest
	# Install Dart dependencies for gRPC
	@cd frontend && flutter pub add grpc protobuf
	@cd frontend && flutter pub get
	# Verify installation
	@echo "Verifying installation..."
	@echo "protoc-gen-go version: $(PROTOC_GEN_GO)"
	@echo "protoc-gen-go-grpc version: $(PROTOC_GEN_GRPC)"
	@echo "protoc-gen-dart version: $(PROTOC_GEN_DART)"
	@curl -s --create-dirs -L -o bin/species.parquet https://fishbase.ropensci.org/fishbase/species.parquet
	@curl -s --create-dirs -L -o bin/comnames_all.parquet https://fishbase.ropensci.org/sealifebase/comnames_all.parquet

