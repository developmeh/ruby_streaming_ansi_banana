.PHONY: install run

install:
	@echo "Installing gems via Bundler..."
	@bundle install

serve:
	@echo "Running the Ruby app..."
	@bundle exec ruby main.rb
