PROTO_SRC := protos
GO_OUT := gen/go
DART_OUT := gen/dart

PROTOC_VERSION := 24.4
PROTOC_BASE_URL := https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTOC_VERSION)
PROTO_FILES := $(shell find $(PROTO_SRC) -name "*.proto")

GO_TOOLS := \
	google.golang.org/protobuf/cmd/protoc-gen-go@latest \
	google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest


SERVER_BINARY_NAME=cmd/server/main.go

run:
	@echo "Starting gRPC server..."
	go run $(SERVER_BINARY_NAME)

.PHONY: generate

generate:
	@mkdir -p $(GO_OUT) $(DART_OUT)
	@for file in $(PROTO_FILES); do \
		protoc -I$(PROTO_SRC) \
			--go_out=$(GO_OUT) --go_opt=paths=source_relative \
			--go-grpc_out=$(GO_OUT) --go-grpc_opt=paths=source_relative \
			--dart_out=$(DART_OUT) \
			$$file; \
	done

.PHONY: deps

deps:
	@echo "🔍 Checking for protoc..."
	@if ! command -v protoc >/dev/null 2>&1; then \
		echo "❌ 'protoc' not found. Downloading protoc $(PROTOC_VERSION)..."; \
		OS=$$(uname -s | tr '[:upper:]' '[:lower:]'); \
		ZIP=protoc-$(PROTOC_VERSION)-$$OS-x86_64.zip; \
		curl -LO $(PROTOC_BASE_URL)/$$ZIP; \
		unzip -o $$ZIP -d protoc_tmp -x 'include/*'; \
		sudo install protoc_tmp/bin/protoc /usr/local/bin/protoc; \
		rm -rf protoc_tmp $$ZIP; \
		echo "✅ Installed protoc to /usr/local/bin/protoc"; \
	else \
		echo "✅ protoc found: $$(protoc --version)"; \
	fi

	@echo "📦 Installing Go protoc plugins..."
	@for tool in $(GO_TOOLS); do \
		echo "Installing $$tool"; \
		go install $$tool; \
	done

	@echo "📦 Ensuring Dart protoc plugin is activated..."
	@dart pub global activate protoc_plugin

	@echo "✅ Done. Make sure your PATH includes Dart's pub cache bin directory:"
	@echo '   export PATH="$$PATH:$$HOME/.pub-cache/bin"'
