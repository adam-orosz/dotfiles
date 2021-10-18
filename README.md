# dotfiles

## Install

Run:

```bash
make
```

After successful `make`, restart computer.

## Manual installation

* [Docker](https://docs.docker.com/desktop/mac/apple-silicon/)

## Change default shell

```bash
which bash | sudo tee -a /etc/shells
chsh -s $(which bash)
sudo chsh -s $(which bash)
```
