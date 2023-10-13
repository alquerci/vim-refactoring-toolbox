call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#extract_method#main#execute() range
    call refactoring_toolbox#usage#increment('PhpExtractMethod')

    call refactoring_toolbox#extract_method#execute(
        \ refactoring_toolbox#adaptor#input#make(),
        \ refactoring_toolbox#adaptor#language#php#make()
    \ )
endfunction

function refactoring_toolbox#extract_method#main#sh() range
    call refactoring_toolbox#usage#increment('ShExtractMethod')

    call refactoring_toolbox#extract_method#execute(
        \ refactoring_toolbox#adaptor#input#make(),
        \ refactoring_toolbox#adaptor#language#sh#make()
    \ )
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
