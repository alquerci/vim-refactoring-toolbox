call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#extract_property#main#execute()
    call refactoring_toolbox#usage#increment('PhpExtractClassProperty')
    call refactoring_toolbox#usage#increment('PhpExtractProperty')

    call refactoring_toolbox#extract_property#php#execute(
        \ refactoring_toolbox#adaptor#vim_texteditor#make(),
    \ )
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
