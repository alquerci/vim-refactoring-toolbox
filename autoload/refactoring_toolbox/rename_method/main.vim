call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#rename_method#main#execute()
    call refactoring_toolbox#usage#increment('PhpRenameMethod')

    call refactoring_toolbox#rename_method#execute(
        \ refactoring_toolbox#adaptor#input#make()
    \ )
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
