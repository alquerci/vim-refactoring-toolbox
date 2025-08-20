call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#rename_property#main#execute()
    call refactoring_toolbox#usage#increment('PhpRenameProperty')

    call refactoring_toolbox#rename_property#property_renamer#execute(
        \ refactoring_toolbox#adapters#input#make(),
        \ refactoring_toolbox#adapters#output#make(),
        \ refactoring_toolbox#adapters#vim_texteditor#construct(),
        \ refactoring_toolbox#rename_property#adapters#php_language#construct(),
    \ )
endfunction

function refactoring_toolbox#rename_property#main#renameClassVariable()
    call refactoring_toolbox#usage#increment('PhpRenameClassVariable')

    call refactoring_toolbox#rename_property#property_renamer#execute(
        \ refactoring_toolbox#adapters#input#make(),
        \ refactoring_toolbox#adapters#output#make(),
        \ refactoring_toolbox#adapters#vim_texteditor#construct(),
        \ refactoring_toolbox#rename_property#adapters#php_language#construct(),
    \ )
endfunction

call refactoring_toolbox#adapters#vim#end_script()
