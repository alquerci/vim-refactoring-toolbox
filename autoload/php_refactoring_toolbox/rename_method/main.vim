call php_refactoring_toolbox#vim#begin_script()

function php_refactoring_toolbox#rename_method#main#execute()
    call php_refactoring_toolbox#usage#increment('PhpRenameMethod')

    call php_refactoring_toolbox#rename_method#execute(
        \ php_refactoring_toolbox#input#make()
    \ )
endfunction

call php_refactoring_toolbox#vim#end_script()
