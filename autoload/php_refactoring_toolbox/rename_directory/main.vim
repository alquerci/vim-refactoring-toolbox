call php_refactoring_toolbox#vim#begin_script()

function php_refactoring_toolbox#rename_directory#main#execute()
    call php_refactoring_toolbox#usage#increment('PhpRenameDirectory')

    call php_refactoring_toolbox#rename_directory#execute(
        \ php_refactoring_toolbox#input#make()
    \ )
endfunction

call php_refactoring_toolbox#vim#end_script()
