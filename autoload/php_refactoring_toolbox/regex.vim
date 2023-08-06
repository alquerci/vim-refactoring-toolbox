" +---------------------------------------------------------------+
" |   VIM REGEXP REMINDER   |    Vim Regex       |   Perl Regex   |
" |===============================================================|
" | Vim non catchable       | \%(.\)             | (?:.)          |
" | Vim negative lookahead  | Start\(Date\)\@!   | Start(?!Date)  |
" | Vim positive lookahead  | Start\(Date\)\@=   | Start(?=Date)  |
" | Vim negative lookbehind | \(Start\)\@<!Date  | (?<!Start)Date |
" | Vim positive lookbehind | \(Start\)\@<=Date  | (?<=Start)Date |
" | Multiline search        | \_s\_.             | \s\. multiline |
" | Before word boundary    | \<WORD             | \b             |
" | After word boundary     |   WORD\>           | \b             |
" +---------------------------------------------------------------+

let php_refactoring_toolbox#regex#class_line  = '^\%(\%(final\s\+\|abstract\s\+\)\?class\>\|trait\>\)'
let php_refactoring_toolbox#regex#func_line = '^\s*\%(\%(private\|protected\|public\|static\|abstract\)\s*\)*function\_s\+'
let php_refactoring_toolbox#regex#member_line = '^\s*\%(\%(private\|protected\|public\|static\)\%(\_s\+?\?[\\|_A-Za-z0-9]\+\)\?\s*\)\+\$'
let php_refactoring_toolbox#regex#const_line = '^\s*const\s\+[^;]\+;'
let php_refactoring_toolbox#regex#local_var = '\$\<\%(this\>\)\@![A-Za-z0-9]*'
let php_refactoring_toolbox#regex#local_var_mutate = '\$\<\%(this\>\)\@![A-Za-z0-9]*\%(\[\_.*\]\)\?\_s*\%([.+*%/&|^-]\|\*\*\|<<\|>>\|??\)\?='
let php_refactoring_toolbox#regex#doc_var_type = '@var '
let php_refactoring_toolbox#regex#before_word_boudary = '\<'
let php_refactoring_toolbox#regex#after_word_boudary = '\>'
