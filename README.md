# homebrew-ygn

Homebrew tap for [ygnstudio](https://github.com/ygnstudio) formulae and casks.

## Usage

Tap the repository:

```bash
brew tap ygnstudio/ygn
```

Install a formula:

```bash
brew install ygnstudio/ygn/<formula>
```

Or install a cask:

```bash
brew install --cask ygnstudio/ygn/<cask>
```

## Available Formulae

| Formula | Description |
|---------|-------------|
| _(add your formulae here)_ | |

## Available Casks

| Cask | Description |
|------|-------------|
| _(add your casks here)_ | |

## Development

Formulae live in [`Formula/`](./Formula) and casks live in [`Casks/`](./Casks).

Test a formula locally:

```bash
brew install --build-from-source ./Formula/<name>.rb
brew test <name>
brew audit --strict --new-formula ./Formula/<name>.rb
```

## License

MIT
