call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#extract_property#main#execute()
    call refactoring_toolbox#usage#increment('PhpExtractClassProperty')
    call refactoring_toolbox#usage#increment('PhpExtractProperty')

    call refactoring_toolbox#extract_property#php#execute(
        \ refactoring_toolbox#adapters#vim_texteditor#construct(),
    \ )
endfunction

call refactoring_toolbox#adapters#vim#end_script()
