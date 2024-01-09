call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#extract_constant#main#extractConstantForPhp()
    call refactoring_toolbox#usage#increment('PhpExtractConst')

    call refactoring_toolbox#extract_constant#constant_extractor#execute(
        \ refactoring_toolbox#adaptor#input#make(),
        \ refactoring_toolbox#extract_constant#adaptor#vim_texteditor#make(),
    \ )
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
