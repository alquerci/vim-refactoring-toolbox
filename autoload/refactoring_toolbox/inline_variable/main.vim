call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#inline_variable#main#execute()
    call refactoring_toolbox#usage#increment('PhpInlineVariable')

    call refactoring_toolbox#inline_variable#variable_inliner#execute(
        \ refactoring_toolbox#inline_variable#adapters#php_language#make(
            \ refactoring_toolbox#adaptor#vim_texteditor#make(),
        \ ),
    \ )
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
