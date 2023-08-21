call refactoring_toolbox#vim#begin_script()

function refactoring_toolbox#rename_variable#main#execute()
    call refactoring_toolbox#usage#increment('PhpRenameVariable')

    call refactoring_toolbox#rename_variable#execute(
        \ refactoring_toolbox#input#make()
    \ )
endfunction

function refactoring_toolbox#rename_variable#main#renameLocalVariable()
    call refactoring_toolbox#usage#increment('PhpRenameLocalVariable')

    call refactoring_toolbox#rename_variable#execute(
        \ refactoring_toolbox#input#make()
    \ )
endfunction

call refactoring_toolbox#vim#end_script()
