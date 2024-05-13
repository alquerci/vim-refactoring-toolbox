let s:before_word_boundary = '\<'
let s:after_word_boundary = '\>'
let s:case_sensitive = '\C'

call refactoring_toolbox#adapters#vim#begin_script()

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

let refactoring_toolbox#adapters#js_regex#reserved_variable = s:reserved_variable

let s:mutation_symbols = '\%(=\|+=\|-=\|\*=\|/=\|%=\|\*\*=\)'
let refactoring_toolbox#adapters#js_regex#mutation_symbols = s:mutation_symbols

let s:var_name = '\%('.s:reserved_variable.'\)\@!\&\%(\.[ \t\n]*\|[a-zA-Z_$]\)\@<!\([a-zA-Z_$][a-zA-Z0-9_$]*\)'
let refactoring_toolbox#adapters#js_regex#var_name = s:var_name

let s:regex_method_line = '\w([^)]*)\_s*{$'
let s:regex_function_line = 'function\_s*\w*\_s*([^)]*)\_s*{$'
let s:regex_arrow_func_line = '\%('.s:var_name.'\|([^)]*)\)\_s*=>'
let refactoring_toolbox#adapters#js_regex#func_line = '\%('.s:regex_arrow_func_line.'\|'.s:regex_method_line.'\|'.s:regex_function_line.'\)'

function refactoring_toolbox#adapters#js_regex#makeLocalVariableDefinition(name)
    return s:case_sensitive.'\%('.s:before_word_boundary.a:name.s:after_word_boundary.'\)\([ \n\t]*'.s:mutation_symbols.'[ \t\n]\)\@='
endfunction

call refactoring_toolbox#adapters#vim#end_script()
