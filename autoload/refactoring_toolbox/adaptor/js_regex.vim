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

let refactoring_toolbox#adaptor#js_regex#reserved_variable = '\<\%('
    \ .join(s:keyword_reserved, '\|').'\|'.join(s:identifiers_spectial_meaning, '\|')
    \ .'\)\>'

call refactoring_toolbox#adaptor#vim#end_script()
