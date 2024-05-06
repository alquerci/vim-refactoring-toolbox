call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#rename_method#main#execute()
    call refactoring_toolbox#usage#increment('PhpRenameMethod')

    call refactoring_toolbox#rename_method#method_renamer#execute(
        \ refactoring_toolbox#adapters#input#make(),
        \ refactoring_toolbox#adapters#output#make(),
        \ refactoring_toolbox#adapters#vim_texteditor#make(),
    \ )
endfunction

call refactoring_toolbox#adapters#vim#end_script()
