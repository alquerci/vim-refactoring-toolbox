call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#rename_method#main#execute()
    call refactoring_toolbox#usage#increment('PhpRenameMethod')

    call refactoring_toolbox#rename_method#method_renamer#execute(
        \ refactoring_toolbox#adaptor#input#make(),
        \ refactoring_toolbox#adaptor#output#make(),
        \ refactoring_toolbox#adaptor#vim_texteditor#make(),
    \ )
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
