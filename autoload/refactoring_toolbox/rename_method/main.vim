call refactoring_toolbox#vim#begin_script()

function refactoring_toolbox#rename_method#main#execute()
    call refactoring_toolbox#usage#increment('PhpRenameMethod')

    call refactoring_toolbox#rename_method#execute(
        \ refactoring_toolbox#input#make()
    \ )
endfunction

call refactoring_toolbox#vim#end_script()
