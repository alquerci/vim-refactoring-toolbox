call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#rename_property#main#execute()
    call refactoring_toolbox#usage#increment('PhpRenameProperty')

    call refactoring_toolbox#rename_property#execute(
        \ refactoring_toolbox#adaptor#input#make()
    \ )
endfunction

function refactoring_toolbox#rename_property#main#renameClassVariable()
    call refactoring_toolbox#usage#increment('PhpRenameClassVariable')

    call refactoring_toolbox#rename_property#execute(
        \ refactoring_toolbox#adaptor#input#make()
    \ )
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
