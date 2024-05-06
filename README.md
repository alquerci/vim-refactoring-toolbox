# VIM Code Refactoring Toolbox

[![License: MIT](https://img.shields.io/github/license/alquerci/vim-refactoring-toolbox)](https://opensource.org/licenses/MIT)

Fork of [`adoy/vim-php-refactoring-toolbox`](https://github.com/adoy/vim-php-refactoring-toolbox).
Big thanks to Pierrick Charron ([@adoy](https://github.com/adoy)).

A set of mappings which help you to refactor code in consistent way across languages.


## Supported languages

- PHP
- Shell
  - Extract Method
- JavaScript
  - Extract Method
  - Extract Variable
  - Inline Variable
  - Rename Variable
- TypeScript
  - Extract Method
  - Extract Variable
  - Inline Variable
  - Rename Variable


## Refactoring Techniques Highlights

To help boy-scout to clean the code.

### To extract till you drop.

* Extract Variable (`<LocalLeader>ev`)
* Extract Method (`<LocalLeader>em`)
* In-line Variable (`<LocalLeader>iv`)
* Extract Property (`<LocalLeader>ep`)

### To make the code easy to read.

* Rename Method (`<LocalLeader>rm`)
* Rename Variable (`<LocalLeader>rv`)
* Extract Constant (`<LocalLeader>ec`)
* Rename Property (`<LocalLeader>rp`)

### To quickly change code location.

* Rename Directory (`<Leader>rd`, required github.com/phpactor/phpactor)

### To generate code

* Create Setters and Getters (`<LocalLeader>sg`)
* Create only Getters (`<LocalLeader>cog`)


## Full Documentation

See [./doc/refactoring-toolbox.txt](./doc/refactoring-toolbox.txt)


## Installation

* [vim-plug](https://github.com/junegunn/vim-plug): `Plug 'alquerci/vim-refactoring-toolbox'`
* [vundle](https://github.com/gmarik/Vundle.vim): `Plugin 'alquerci/vim-refactoring-toolbox'`
* [pathogen](https://github.com/tpope/vim-pathogen): `git clone https://github.com/alquerci/vim-refactoring-toolbox.git ~/.vim/bundle/`


## Running tests

```
bin/test
```

### How to write tests?

See https://github.com/junegunn/vader.vim
