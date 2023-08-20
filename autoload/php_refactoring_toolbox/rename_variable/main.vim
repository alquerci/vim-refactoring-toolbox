call php_refactoring_toolbox#vim#begin_script()

function php_refactoring_toolbox#rename_variable#main#execute()
    call php_refactoring_toolbox#usage#increment('PhpRenameVariable')

    call php_refactoring_toolbox#rename_variable#execute(
        \ php_refactoring_toolbox#input#make()
    \ )
endfunction

function php_refactoring_toolbox#rename_variable#main#renameLocalVariable()
    call php_refactoring_toolbox#usage#increment('PhpRenameLocalVariable')

    call php_refactoring_toolbox#rename_variable#execute(
        \ php_refactoring_toolbox#input#make()
    \ )
endfunction

call php_refactoring_toolbox#vim#end_script()
