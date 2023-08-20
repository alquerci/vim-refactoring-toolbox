call php_refactoring_toolbox#vim#begin_script()

function php_refactoring_toolbox#extract_variable#main#execute() range
    call php_refactoring_toolbox#usage#increment('PhpExtractVariable')

    call php_refactoring_toolbox#extract_variable#execute(
        \ php_refactoring_toolbox#input#make()
    \ )
endfunction

call php_refactoring_toolbox#vim#end_script()
