# Quirkdom Tap

Homebrew tap for Quirkdom tools.

## Available Formulae

- **[`catpult`](https://github.com/quirkdom/catpult)** - Peer-to-peer file sharing & streaming over secure, ephemeral tunnels. Powered by Tailcat and WireGuard®.
- **[`calm`](https://github.com/quirkdom/calm)** - Terminal-native CLI assistant backed by a local calmd daemon.

## Installation

```sh
brew install quirkdom/tap/<formula>
```

For example, to install `catpult`:

```sh
brew install quirkdom/tap/catpult
```

Or tap first and then install:

```sh
brew tap quirkdom/tap
brew install catpult
```

Or, in a `brew bundle` `Brewfile`:

```ruby
tap "quirkdom/tap"
brew "catpult"
```

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
