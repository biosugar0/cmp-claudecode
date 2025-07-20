# Contributing to cmp-claudecode

Thank you for your interest in contributing to cmp-claudecode! This document provides guidelines for contributing to the project.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/cmp-claudecode.git`
3. Create a new branch: `git checkout -b feature/your-feature-name`

## Development Setup

1. Ensure you have Neovim 0.7+ installed
2. Install development dependencies:
   - [luacheck](https://github.com/mpeterv/luacheck) for linting
   - [stylua](https://github.com/JohnnyMorganz/StyLua) for formatting

## Code Style

- Run `make lint` to check your code with luacheck
- Format your code with stylua (configuration is in `.stylua.toml`)
- Follow existing code patterns and conventions

## Testing

1. Run basic tests: `make test-basic`
2. Run full test suite: `make test-full` (requires plenary.nvim)
3. Add tests for new features in the `test/` directory

## Commit Guidelines

- Use conventional commit format: `type: description`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- Keep commits focused and atomic
- Write clear, descriptive commit messages

## Pull Request Process

1. Update the README.md with details of changes if needed
2. Update the CHANGELOG.md following the existing format
3. Ensure all tests pass
4. Update documentation if you're changing functionality
5. Submit your PR with a clear description of the changes

## Reporting Issues

- Use the issue tracker to report bugs
- Provide a minimal reproducible example
- Include your Neovim version and configuration
- Describe expected vs actual behavior

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help maintain a positive community

## Questions?

Feel free to open an issue for any questions about contributing!