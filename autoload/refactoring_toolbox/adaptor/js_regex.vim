call refactoring_toolbox#adaptor#vim#begin_script()

let s:keyword_reserved = [
    \ 'await',
    \ 'break',
    \ 'case',
    \ 'catch',
    \ 'class',
    \ 'const',
    \ 'continue',
    \ 'debugger',
    \ 'default',
    \ 'delete',
    \ 'do',
    \ 'else',
    \ 'export',
    \ 'extends',
    \ 'false',
    \ 'finally',
    \ 'for',
    \ 'function',
    \ 'if',
    \ 'import',
    \ 'in',
    \ 'instanceof',
    \ 'let',
    \ 'new',
    \ 'null',
    \ 'return',
    \ 'static',
    \ 'super',
    \ 'switch',
    \ 'this',
    \ 'throw',
    \ 'true',
    \ 'try',
    \ 'typeof',
    \ 'var',
    \ 'void',
    \ 'while',
    \ 'with',
    \ 'yield',
\ ]

let s:identifiers_spectial_meaning = [
    \ 'arguments',
    \ 'async',
    \ 'eval',
    \ 'get',
    \ 'of',
    \ 'set',
\ ]

let s:reserved_variable = '\<\%('
    \ .join(s:keyword_reserved, '\|').'\|'.join(s:identifiers_spectial_meaning, '\|')
    \ .'\)\>'

let refactoring_toolbox#adaptor#js_regex#reserved_variable = s:reserved_variable

let refactoring_toolbox#adaptor#js_regex#mutation_symbols = '\%(=\|+=\|-=\|\*=\|/=\|%=\|\*\*=\)'

let refactoring_toolbox#adaptor#js_regex#var_name = '\%('.s:reserved_variable.'\)\@!\&\%(\.[ \t\n]*\|[a-zA-Z_$]\)\@<!\([a-zA-Z_$][a-zA-Z0-9_$]*\)'

let s:regex_method_line = '\w([^)]*)\_s*{$'
let s:regex_arrow_func_line = '=>'
let refactoring_toolbox#adaptor#js_regex#func_line = '\%('.s:regex_arrow_func_line.'\|'.s:regex_method_line.'\)'

call refactoring_toolbox#adaptor#vim#end_script()
