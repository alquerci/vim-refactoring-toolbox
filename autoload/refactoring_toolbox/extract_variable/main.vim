call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#extract_variable#main#execute() range
    call refactoring_toolbox#usage#increment('PhpExtractVariable')

    call refactoring_toolbox#extract_variable#variable_extractor#execute(
        \ refactoring_toolbox#adapters#input#make(),
        \ refactoring_toolbox#extract_variable#adapters#php_language#make(),
    \ )
endfunction

function refactoring_toolbox#extract_variable#main#extractVariableForJavascript() range
    call refactoring_toolbox#usage#increment('JsExtractVariable')

    call refactoring_toolbox#extract_variable#variable_extractor#execute(
        \ refactoring_toolbox#adapters#input#make(),
        \ refactoring_toolbox#extract_variable#adapters#js_language#make(),
    \ )
endfunction

function refactoring_toolbox#extract_variable#main#extractVariableForTypescript() range
    call refactoring_toolbox#usage#increment('TsExtractVariable')

    call refactoring_toolbox#extract_variable#variable_extractor#execute(
        \ refactoring_toolbox#adapters#input#make(),
        \ refactoring_toolbox#extract_variable#adapters#js_language#make(),
    \ )
endfunction

function refactoring_toolbox#extract_variable#main#extractVariableForVim() range
    call refactoring_toolbox#usage#increment('VimExtractVariable')

    call refactoring_toolbox#extract_variable#variable_extractor#execute(
        \ refactoring_toolbox#adapters#input#make(),
        \ refactoring_toolbox#extract_variable#adapters#vim_language#make(),
    \ )
endfunction

call refactoring_toolbox#adapters#vim#end_script()
