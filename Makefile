.PHONY: test test-basic test-full test-perf lint clean

test: test-basic

test-basic:
	@echo "Running basic tests..."
	@nvim --headless --noplugin -u NONE -c "luafile test/basic_test.lua" +q

test-full:
	@echo "Running full test suite with Plenary..."
	@bash test/test.sh

test-perf:
	@echo "Running performance tests..."
	@nvim --headless -u test/minimal_init.lua -c "PlenaryBustedFile test/performance_test.lua"

lint:
	@echo "Running luacheck..."
	@luacheck lua/

clean:
	@echo "Cleaning up..."
	@find . -name "*.log" -delete
	@rm -rf /tmp/nvim-test-deps
	@rm -rf /tmp/nvim-cmp-claudecode-test-deps

help:
	@echo "Available targets:"
	@echo "  test       - Run basic tests (default)"
	@echo "  test-basic - Run basic tests without dependencies"
	@echo "  test-full  - Run full test suite with Plenary"
	@echo "  test-perf  - Run performance tests"
	@echo "  lint       - Run luacheck"
	@echo "  clean      - Clean up temporary files"