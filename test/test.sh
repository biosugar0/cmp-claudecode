#!/bin/bash

# Simple test runner script

echo "Installing test dependencies..."

# Create temp directory for test dependencies
TEST_DEPS_DIR="/tmp/nvim-cmp-claudecode-test-deps"
mkdir -p "$TEST_DEPS_DIR"

# Install plenary.nvim
if [ ! -d "$TEST_DEPS_DIR/plenary.nvim" ]; then
    git clone --depth 1 https://github.com/nvim-lua/plenary.nvim "$TEST_DEPS_DIR/plenary.nvim"
fi

# Install nvim-cmp
if [ ! -d "$TEST_DEPS_DIR/nvim-cmp" ]; then
    git clone --depth 1 https://github.com/hrsh7th/nvim-cmp "$TEST_DEPS_DIR/nvim-cmp"
fi

echo "Running tests..."

# Run tests with proper runtimepath
nvim --headless --noplugin \
    --cmd "set rtp+=$TEST_DEPS_DIR/plenary.nvim" \
    --cmd "set rtp+=$TEST_DEPS_DIR/nvim-cmp" \
    --cmd "set rtp+=." \
    -c "runtime plugin/plenary.vim" \
    -c "lua require('plenary.busted')" \
    -c "PlenaryBustedDirectory test/ { minimal_init = 'test/minimal_init.lua' }" \
    -c "qa!"