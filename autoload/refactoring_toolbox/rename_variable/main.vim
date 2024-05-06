call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#rename_variable#main#execute()
    call refactoring_toolbox#usage#increment('PhpRenameVariable')

    call refactoring_toolbox#rename_variable#variable_renamer#execute(
        \ refactoring_toolbox#rename_variable#adapters#php_language#make(),
        \ refactoring_toolbox#adaptor#input#make(),
        \ refactoring_toolbox#adaptor#output#make(),
        \ refactoring_toolbox#adaptor#vim_texteditor#make(),
    \ )
endfunction

function refactoring_toolbox#rename_variable#main#renameLocalVariable()
    call refactoring_toolbox#usage#increment('PhpRenameLocalVariable')

    call refactoring_toolbox#rename_variable#variable_renamer#execute(
        \ refactoring_toolbox#rename_variable#adapters#php_language#make(),
        \ refactoring_toolbox#adaptor#input#make(),
        \ refactoring_toolbox#adaptor#output#make(),
        \ refactoring_toolbox#adaptor#vim_texteditor#make(),
    \ )
endfunction

function refactoring_toolbox#rename_variable#main#renameVariableForTypescript()
    call refactoring_toolbox#usage#increment('TsRenameVariable')

    call refactoring_toolbox#rename_variable#variable_renamer#execute(
        \ refactoring_toolbox#rename_variable#adapters#ts_language#make(),
        \ refactoring_toolbox#adaptor#input#make(),
        \ refactoring_toolbox#adaptor#output#make(),
        \ refactoring_toolbox#adaptor#vim_texteditor#make(),
    \ )
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
