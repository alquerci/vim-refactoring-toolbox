# VIM Php Refactoring Toolbox

[![License: MIT](https://img.shields.io/github/license/adoy/vim-php-refactoring-toolbox)](https://opensource.org/licenses/MIT)

PHP Refactoring Toolbox for VIM

* Rename Method
* Rename Directory (required phpactor/phpactor)
* Rename Local Variable
* Rename Class Variable
* In-line Variable
* Extract Method
* Extract Variable
* Extract Constant
* Extract Class Property
* Extract Use
* Create setters and getters
* Create Property
* Detect Unused Use Statements
* Align Assigns
* Document all code

## Installation

* [vim-plug](https://github.com/junegunn/vim-plug): `Plug 'adoy/vim-php-refactoring-toolbox'`
* [vundle](https://github.com/gmarik/Vundle.vim): `Plugin 'adoy/vim-php-refactoring-toolbox'`
* [pathogen](https://github.com/tpope/vim-pathogen): `git clone https://github.com/adoy/vim-php-refactoring-toolbox.git ~/.vim/bundle/`
* or just copy the `plugin/php-refactoring-toolbox.vim` in your `~/.vim/plugin` folder

## Documentation

See [](./doc/refactoring-toolbox.txt)


## Running tests

```
bin/test
```

### How to write tests?

See https://github.com/junegunn/vader.vim
