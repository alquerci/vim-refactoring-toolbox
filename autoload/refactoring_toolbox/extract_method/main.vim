call refactoring_toolbox#vim#begin_script()

function refactoring_toolbox#extract_method#main#execute() range
    call refactoring_toolbox#usage#increment('PhpExtractMethod')

    call refactoring_toolbox#extract_method#execute(
        \ refactoring_toolbox#input#make()
    \ )
endfunction

call refactoring_toolbox#vim#end_script()
