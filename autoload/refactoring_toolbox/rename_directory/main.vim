call refactoring_toolbox#vim#begin_script()

function refactoring_toolbox#rename_directory#main#execute()
    call refactoring_toolbox#usage#increment('PhpRenameDirectory')

    call refactoring_toolbox#rename_directory#execute(
        \ refactoring_toolbox#input#make()
    \ )
endfunction

call refactoring_toolbox#vim#end_script()
