call php_refactoring_toolbox#vim#begin_script()

function php_refactoring_toolbox#rename_property#main#execute()
    call php_refactoring_toolbox#usage#increment('PhpRenameProperty')

    call php_refactoring_toolbox#rename_property#execute(
        \ php_refactoring_toolbox#input#make()
    \ )
endfunction

function php_refactoring_toolbox#rename_property#main#renameClassVariable()
    call php_refactoring_toolbox#usage#increment('PhpRenameClassVariable')

    call php_refactoring_toolbox#rename_property#execute(
        \ php_refactoring_toolbox#input#make()
    \ )
endfunction

call php_refactoring_toolbox#vim#end_script()
