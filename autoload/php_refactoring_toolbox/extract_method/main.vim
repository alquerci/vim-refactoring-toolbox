call php_refactoring_toolbox#vim#begin_script()

function php_refactoring_toolbox#extract_method#main#execute() range
    call php_refactoring_toolbox#usage#increment('PhpExtractMethod')

    call php_refactoring_toolbox#extract_method#execute(
        \ php_refactoring_toolbox#input#make()
    \ )
endfunction

call php_refactoring_toolbox#vim#end_script()
