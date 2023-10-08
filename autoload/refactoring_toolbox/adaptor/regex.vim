call refactoring_toolbox#adaptor#vim#begin_script()

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

let s:modifier_visibility = '\%(private\|protected\|public\)'
let s:modifier_scope = '\%(static\|readonly\)'
let s:type_declaration = '\%(?\?[\\|_A-Za-z0-9]\+\)'

let refactoring_toolbox#adaptor#regex#class_line  = '^\%(\%(final\s\+\|abstract\s\+\)\?class\>\|trait\>\)'
let refactoring_toolbox#adaptor#regex#func_line = '^\s*\%(\%(private\|protected\|public\|static\|abstract\)\s*\)*function\_s\+'
let refactoring_toolbox#adaptor#regex#static_func = 'static\s\+'.s:modifier_visibility.'\?\s*\(function\)\@='

let s:visibility_or_scope_property_modifiers = '\%(\%('.s:modifier_visibility.'\|'.s:modifier_scope.'\)\s\+\)\{1,2}'
let s:member = '\s*\%('.s:visibility_or_scope_property_modifiers.'\%('.s:type_declaration.'\s\+\)\?\)\$'
let refactoring_toolbox#adaptor#regex#member_line = '^'.s:member

let refactoring_toolbox#adaptor#regex#member_declaration_or_usage = '\%('.s:member.'\|$this->\)'

let refactoring_toolbox#adaptor#regex#const_line = '^\s*const\s\+[^;]\+;'
let refactoring_toolbox#adaptor#regex#local_var = '\$\<\%(this\>\)\@![A-Za-z0-9]*'
let refactoring_toolbox#adaptor#regex#local_var_mutate = '\$\<\%(this\>\)\@![A-Za-z0-9]*\%(\[\_.*\]\)\?\_s*\%([.+*%/&|^-]\|\*\*\|<<\|>>\|??\)\?='
let refactoring_toolbox#adaptor#regex#doc_var_type = '@var '
let refactoring_toolbox#adaptor#regex#before_word_boudary = '\<'
let refactoring_toolbox#adaptor#regex#after_word_boudary = '\>'
let refactoring_toolbox#adaptor#regex#case_sensitive = '\C'
let refactoring_toolbox#adaptor#regex#case_ignore = '\c'
let refactoring_toolbox#adaptor#regex#lookbehind_positive = '\@<='

call refactoring_toolbox#adaptor#vim#end_script()
