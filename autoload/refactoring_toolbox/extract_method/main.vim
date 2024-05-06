call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#extract_method#main#extractMethodForPhp() range
    call refactoring_toolbox#usage#increment('PhpExtractMethod')

    call refactoring_toolbox#extract_method#method_extractor#extractSelectedBlock(
        \ refactoring_toolbox#adapters#input#make(),
        \ refactoring_toolbox#extract_method#adapters#php_language#make(
            \ refactoring_toolbox#extract_method#adapters#vim_position#make()
        \ ),
        \ refactoring_toolbox#extract_method#adapters#vim_texteditor#make(
            \ refactoring_toolbox#extract_method#adapters#vim_position#make()
        \ ),
        \ refactoring_toolbox#extract_method#adapters#output#make()
    \ )
endfunction

function refactoring_toolbox#extract_method#main#extractMethodForSh() range
    call refactoring_toolbox#usage#increment('ShExtractMethod')

    call refactoring_toolbox#extract_method#method_extractor#extractSelectedBlock(
        \ refactoring_toolbox#adapters#input#make(),
        \ refactoring_toolbox#extract_method#adapters#sh_language#make(
            \ refactoring_toolbox#extract_method#adapters#vim_position#make()
        \ ),
        \ refactoring_toolbox#extract_method#adapters#vim_texteditor#make(
            \ refactoring_toolbox#extract_method#adapters#vim_position#make()
        \ ),
        \ refactoring_toolbox#extract_method#adapters#output#make()
    \ )
endfunction

function refactoring_toolbox#extract_method#main#extractMethodForJavascript() range
    call refactoring_toolbox#usage#increment('JsExtractMethod')

    call refactoring_toolbox#extract_method#method_extractor#extractSelectedBlock(
        \ refactoring_toolbox#adapters#input#make(),
        \ refactoring_toolbox#extract_method#adapters#js_language#make(
            \ refactoring_toolbox#extract_method#adapters#vim_position#make()
        \ ),
        \ refactoring_toolbox#extract_method#adapters#vim_texteditor#make(
            \ refactoring_toolbox#extract_method#adapters#vim_position#make()
        \ ),
        \ refactoring_toolbox#extract_method#adapters#output#make()
    \ )
endfunction

function refactoring_toolbox#extract_method#main#extractMethodForTypescript() range
    call refactoring_toolbox#usage#increment('TsExtractMethod')

    call refactoring_toolbox#extract_method#method_extractor#extractSelectedBlock(
        \ refactoring_toolbox#adapters#input#make(),
        \ refactoring_toolbox#extract_method#adapters#ts_language#make(
            \ refactoring_toolbox#extract_method#adapters#vim_position#make()
        \ ),
        \ refactoring_toolbox#extract_method#adapters#vim_texteditor#make(
            \ refactoring_toolbox#extract_method#adapters#vim_position#make()
        \ ),
        \ refactoring_toolbox#extract_method#adapters#output#make()
    \ )
endfunction

call refactoring_toolbox#adapters#vim#end_script()
