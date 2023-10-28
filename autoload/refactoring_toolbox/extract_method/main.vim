call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#extract_method#main#extractMethodForPhp() range
    call refactoring_toolbox#usage#increment('PhpExtractMethod')

    call refactoring_toolbox#extract_method#method_extractor#extractSelectedBlock(
        \ refactoring_toolbox#adaptor#input#make(),
        \ refactoring_toolbox#extract_method#adaptor#php_language#make(),
        \ refactoring_toolbox#extract_method#adaptor#vim_texteditor#make(),
        \ refactoring_toolbox#extract_method#adaptor#output#make()
    \ )
endfunction

function refactoring_toolbox#extract_method#main#extractMethodForSh() range
    call refactoring_toolbox#usage#increment('ShExtractMethod')

    call refactoring_toolbox#extract_method#method_extractor#extractSelectedBlock(
        \ refactoring_toolbox#adaptor#input#make(),
        \ refactoring_toolbox#extract_method#adaptor#sh_language#make(),
        \ refactoring_toolbox#extract_method#adaptor#vim_texteditor#make(),
        \ refactoring_toolbox#extract_method#adaptor#output#make()
    \ )
endfunction

function refactoring_toolbox#extract_method#main#extractMethodForJs() range
    call refactoring_toolbox#usage#increment('JsExtractMethod')

    call refactoring_toolbox#extract_method#method_extractor#extractSelectedBlock(
        \ refactoring_toolbox#adaptor#input#make(),
        \ refactoring_toolbox#extract_method#adaptor#js_language#make(),
        \ refactoring_toolbox#extract_method#adaptor#vim_texteditor#make(),
        \ refactoring_toolbox#extract_method#adaptor#output#make()
    \ )
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
