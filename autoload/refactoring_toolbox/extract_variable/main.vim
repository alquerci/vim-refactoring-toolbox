call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#extract_variable#main#execute() range
    call refactoring_toolbox#usage#increment('PhpExtractVariable')

    call refactoring_toolbox#extract_variable#variable_extractor#execute(
        \ refactoring_toolbox#adaptor#input#make(),
        \ refactoring_toolbox#extract_variable#adaptor#php_language#make(),
    \ )
endfunction

function refactoring_toolbox#extract_variable#main#extractVariableForJs() range
    call refactoring_toolbox#usage#increment('JsExtractVariable')

    call refactoring_toolbox#extract_variable#variable_extractor#execute(
        \ refactoring_toolbox#adaptor#input#make(),
        \ refactoring_toolbox#extract_variable#adaptor#js_language#make(),
    \ )
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
