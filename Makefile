.PHONY: check test lint help

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

check-shell: ## Run shellcheck on all shell scripts
	shellcheck -e SC1091 \
		scripts/*.sh \
		$(shell find . -name "*.sh" ! -path "*/node_modules/*")

test: check-shell ## Run shellcheck and other tests

lint: check-shell ## Run linters

install-checkers: ## Install required checkers (shellcheck)
	@echo "Installing shellcheck..."
	curl -s https://raw.githubusercontent.com/koalaman/shellcheck-release/master/install.sh | sh -s -- -b /usr/local/bin/
	@echo "Shellcheck installed successfully"
