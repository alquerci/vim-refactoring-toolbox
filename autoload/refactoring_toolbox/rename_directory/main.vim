call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#rename_directory#main#execute()
    call refactoring_toolbox#usage#increment('PhpRenameDirectory')

    call refactoring_toolbox#rename_directory#directory_renamer#execute(
        \ refactoring_toolbox#adapters#input#make(),
        \ refactoring_toolbox#adapters#phpactor#make(),
    \ )
endfunction

call refactoring_toolbox#adapters#vim#end_script()
