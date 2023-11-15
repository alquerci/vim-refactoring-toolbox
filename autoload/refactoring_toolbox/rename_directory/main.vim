call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#rename_directory#main#execute()
    call refactoring_toolbox#usage#increment('PhpRenameDirectory')

    call refactoring_toolbox#rename_directory#directory_renamer#execute(
        \ refactoring_toolbox#adaptor#input#make(),
        \ refactoring_toolbox#adaptor#phpactor#make(),
    \ )
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
