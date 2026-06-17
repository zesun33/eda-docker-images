# Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) in the portfolio repo for the full engineering standard.

## Scope

This repo provides containerized hardware development environments. Changes should:
- Not break any existing image build
- Add or update smoke tests for any new tool
- Keep version pins documented in `versions.env`
- Prefer `apt` packages when available over source builds

## Pull request checklist

- [ ] Image builds without errors
- [ ] Smoke test passes inside the image
- [ ] Version pins updated in `versions.env`
- [ ] README updated if adding a new tool or image

## License

By contributing, you agree to the [Apache-2.0 License](./LICENSE).
