call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#rename_property#main#execute()
    call refactoring_toolbox#usage#increment('PhpRenameProperty')

    call refactoring_toolbox#rename_property#property_renamer#execute(
        \ refactoring_toolbox#adaptor#input#make(),
        \ refactoring_toolbox#adaptor#output#make(),
        \ refactoring_toolbox#adaptor#vim_texteditor#make(),
    \ )
endfunction

function refactoring_toolbox#rename_property#main#renameClassVariable()
    call refactoring_toolbox#usage#increment('PhpRenameClassVariable')

    call refactoring_toolbox#rename_property#property_renamer#execute(
        \ refactoring_toolbox#adaptor#input#make(),
        \ refactoring_toolbox#adaptor#output#make(),
        \ refactoring_toolbox#adaptor#vim_texteditor#make(),
    \ )
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
