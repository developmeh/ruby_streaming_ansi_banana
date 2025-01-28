.PHONY: install serve build-docker

install:
	@echo "Installing gems via Bundler..."
	@bundle install

serve:
	@echo "Running the Ruby app..."
	@bundle exec ruby main.rb

build-docker:
	@echo "Building Docker Image with Nix"
	@nix build
	@docker load < result