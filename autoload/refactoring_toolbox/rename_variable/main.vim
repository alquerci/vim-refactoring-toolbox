call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#rename_variable#main#execute()
    call refactoring_toolbox#usage#increment('PhpRenameVariable')

    call refactoring_toolbox#rename_variable#variable_renamer#execute(
        \ refactoring_toolbox#rename_variable#adapters#php_language#make(),
        \ refactoring_toolbox#adapters#input#make(),
        \ refactoring_toolbox#adapters#output#make(),
        \ refactoring_toolbox#adapters#vim_texteditor#construct(),
    \ )
endfunction

function refactoring_toolbox#rename_variable#main#renameLocalVariable()
    call refactoring_toolbox#usage#increment('PhpRenameLocalVariable')

    call refactoring_toolbox#rename_variable#variable_renamer#execute(
        \ refactoring_toolbox#rename_variable#adapters#php_language#make(),
        \ refactoring_toolbox#adapters#input#make(),
        \ refactoring_toolbox#adapters#output#make(),
        \ refactoring_toolbox#adapters#vim_texteditor#construct(),
    \ )
endfunction

function refactoring_toolbox#rename_variable#main#renameVariableForJavascript()
    call refactoring_toolbox#usage#increment('JsRenameVariable')

    call refactoring_toolbox#rename_variable#variable_renamer#execute(
        \ refactoring_toolbox#rename_variable#adapters#js_language#make(),
        \ refactoring_toolbox#adapters#input#make(),
        \ refactoring_toolbox#adapters#output#make(),
        \ refactoring_toolbox#adapters#vim_texteditor#construct(),
    \ )
endfunction

function refactoring_toolbox#rename_variable#main#renameVariableForTypescript()
    call refactoring_toolbox#usage#increment('TsRenameVariable')

    call refactoring_toolbox#rename_variable#variable_renamer#execute(
        \ refactoring_toolbox#rename_variable#adapters#ts_language#make(),
        \ refactoring_toolbox#adapters#input#make(),
        \ refactoring_toolbox#adapters#output#make(),
        \ refactoring_toolbox#adapters#vim_texteditor#construct(),
    \ )
endfunction

function refactoring_toolbox#rename_variable#main#renameVariableForVim()
    call refactoring_toolbox#usage#increment('VimRenameVariable')

    call refactoring_toolbox#rename_variable#variable_renamer#execute(
        \ refactoring_toolbox#rename_variable#adapters#vim_language#make(),
        \ refactoring_toolbox#adapters#input#make(),
        \ refactoring_toolbox#adapters#output#make(),
        \ refactoring_toolbox#adapters#vim_texteditor#construct(),
    \ )
endfunction

call refactoring_toolbox#adapters#vim#end_script()
