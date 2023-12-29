call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#rename_variable#main#execute()
    call refactoring_toolbox#usage#increment('PhpRenameVariable')

    call refactoring_toolbox#rename_variable#variable_renamer#execute(
        \ refactoring_toolbox#adaptor#input#make(),
        \ refactoring_toolbox#adaptor#output#make()
    \ )
endfunction

function refactoring_toolbox#rename_variable#main#renameLocalVariable()
    call refactoring_toolbox#usage#increment('PhpRenameLocalVariable')

    call refactoring_toolbox#rename_variable#variable_renamer#execute(
        \ refactoring_toolbox#adaptor#input#make(),
        \ refactoring_toolbox#adaptor#output#make()
    \ )
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
