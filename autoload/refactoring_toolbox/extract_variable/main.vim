call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#extract_variable#main#execute() range
    call refactoring_toolbox#usage#increment('PhpExtractVariable')

    call refactoring_toolbox#extract_variable#execute(
        \ refactoring_toolbox#adaptor#input#make()
    \ )
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
