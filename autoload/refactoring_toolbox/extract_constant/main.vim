call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#extract_constant#main#extractConstantForPhp() range
    call refactoring_toolbox#usage#increment('PhpExtractConst')

    call refactoring_toolbox#extract_constant#constant_extractor#execute(
        \ refactoring_toolbox#adapters#input#make(),
        \ refactoring_toolbox#adapters#output#make(),
        \ refactoring_toolbox#extract_constant#adapters#vim_texteditor#make(),
    \ )
endfunction

call refactoring_toolbox#adapters#vim#end_script()
