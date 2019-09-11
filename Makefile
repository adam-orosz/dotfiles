SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.SECONDEXPANSION:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
endif
.RECIPEPREFIX = >

clean:
> ./clean

setup: clean
> mkdir -p ~/code/go
> mkdir -p ~/code/python
> ./setup

setup-linux:
> ./setup-linux