call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#inline_variable#main#execute()
    call refactoring_toolbox#usage#increment('PhpInlineVariable')

    call refactoring_toolbox#inline_variable#variable_inliner#execute(
        \ refactoring_toolbox#inline_variable#adapters#php_language#make(
            \ refactoring_toolbox#adapters#vim_texteditor#construct(),
        \ ),
    \ )
endfunction

function refactoring_toolbox#inline_variable#main#inlineVariableForJavascript()
    call refactoring_toolbox#usage#increment('JsInlineVariable')

    call refactoring_toolbox#inline_variable#variable_inliner#execute(
        \ refactoring_toolbox#inline_variable#adapters#js_language#make(
            \ refactoring_toolbox#adapters#vim_texteditor#construct(),
        \ ),
    \ )
endfunction

function refactoring_toolbox#inline_variable#main#inlineVariableForTypescript()
    call refactoring_toolbox#usage#increment('TsInlineVariable')

    call refactoring_toolbox#inline_variable#variable_inliner#execute(
        \ refactoring_toolbox#inline_variable#adapters#js_language#make(
            \ refactoring_toolbox#adapters#vim_texteditor#construct(),
        \ ),
    \ )
endfunction

call refactoring_toolbox#adapters#vim#end_script()
