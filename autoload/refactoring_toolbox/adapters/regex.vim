call refactoring_toolbox#adapters#vim#begin_script()

" +----------------------------------------------------------------+
" |   VIM REGEXP REMINDER   |    Vim Regex        |   Perl Regex   |
" |================================================================|
" | Vim non catchable       | \%(.\)              | (?:.)          |
" | Vim negative lookahead  | Start\(Date\)\@!    | Start(?!Date)  |
" | Vim positive lookahead  | Start\(Date\)\@=    | Start(?=Date)  |
" | Vim negative lookbehind | \%(Start\)\@<!Date  | (?<!Start)Date |
" | Vim positive lookbehind | \%(Start\)\@<=Date  | (?<=Start)Date |
" | Multiline search        | \_s\_.              | \s\. multiline |
" | Before word boundary    | \<WORD              | \b             |
" | After word boundary     |   WORD\>            | \b             |
" +----------------------------------------------------------------+

let s:before_word_boundary = '\<'
let s:after_word_boundary = '\>'
let s:case_sensitive = '\C'

let refactoring_toolbox#adapters#regex#before_word_boundary = s:before_word_boundary
let refactoring_toolbox#adapters#regex#after_word_boundary = s:after_word_boundary
let refactoring_toolbox#adapters#regex#case_sensitive = s:case_sensitive
let refactoring_toolbox#adapters#regex#case_ignore = '\c'
let refactoring_toolbox#adapters#regex#lookbehind_positive = '\@<='

"
" PHP
"

let s:modifier_visibility = '\%(private\|protected\|public\)'
let s:modifier_scope = '\%(static\|readonly\)'
let s:type_declaration = '\%(?\?[\\|_A-Za-z0-9]\+\)'
let s:variable_name = s:before_word_boundary.'\%([A-Za-z][A-Za-z0-9]*\)'.s:after_word_boundary
let s:mutation_symbol = '\%(\%([.+*%/&|^-]\|\*\*\|<<\|>>\|??\)\?=\)'
let s:array_access = '\%(\[\_.*\]\)'

let s:local_variable_prefix = '\$\(this->\)\@!'
let s:local_variable
    \ = '\%('.s:local_variable_prefix.'\)\@<='.s:variable_name

let refactoring_toolbox#adapters#regex#class_line  = '^\%(\%(final\s\+\|abstract\s\+\)\?class\|trait\)'.s:after_word_boundary
let refactoring_toolbox#adapters#regex#func_line = '^\s*\%(\%(private\|protected\|public\|static\|abstract\)\s*\)*function\_s\+'
let refactoring_toolbox#adapters#regex#static_func = 'static\s\+'.s:modifier_visibility.'\?\s*\(function\)\@='

let s:visibility_or_scope_property_modifiers = '\%(\%('.s:modifier_visibility.'\|'.s:modifier_scope.'\)\s\+\)\{1,2}'
let s:member_declaration  = '\s*\%('.s:visibility_or_scope_property_modifiers.'\%('.s:type_declaration.'\s\+\)\?\)\$'
let refactoring_toolbox#adapters#regex#member_line = '^'.s:member_declaration

let refactoring_toolbox#adapters#regex#member_declaration_or_usage = '\%('.s:member_declaration.'\|$this->\)'

let s:constant_declaration = '\s*\%(const\s\+\)'
let refactoring_toolbox#adapters#regex#constant_declaration_or_usage = '\%('.s:constant_declaration.'\|self::\)'

let refactoring_toolbox#adapters#regex#const_line = '^'.s:constant_declaration.'[^;]\+;'
let refactoring_toolbox#adapters#regex#local_var_prefix = s:local_variable_prefix
let refactoring_toolbox#adapters#regex#local_var = s:local_variable
let refactoring_toolbox#adapters#regex#local_var_mutate
    \ = s:local_variable.'\('.s:array_access.'\?'.'\_s*'.s:mutation_symbol.'\)\@='

function refactoring_toolbox#adapters#regex#makeLocalVariableDefinition(name)
    return s:case_sensitive.'$'.a:name.'\('.s:array_access.'\?'.'\_s*'.s:mutation_symbol.'\)\@='
endfunction

let refactoring_toolbox#adapters#regex#doc_var_type = '@var '

call refactoring_toolbox#adapters#vim#end_script()
