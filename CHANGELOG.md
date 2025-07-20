# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2024-01-21

### Added
- Initial release of cmp-claudecode
- File reference completion with `@` trigger
- Slash command completion with `/` trigger
- Async file scanning for better performance
- LRU cache implementation with TTL support
- Debounced input handling (50ms)
- Support for custom commands in `.claude/commands/`
- Comprehensive test suite
- GitHub Actions CI/CD pipeline
- Full documentation with vim help file

### Features
- Minimal configuration with only `max_items` option
- Automatic discovery of project and user commands
- Simple prefix/substring matching for fast filtering
- nvim-cmp source interface implementation
- Debug mode for troubleshooting

[Unreleased]: https://github.com/biosugar0/cmp-claudecode/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/biosugar0/cmp-claudecode/releases/tag/v0.1.0