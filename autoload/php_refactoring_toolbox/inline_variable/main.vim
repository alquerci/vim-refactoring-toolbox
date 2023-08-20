call php_refactoring_toolbox#vim#begin_script()

function php_refactoring_toolbox#inline_variable#main#execute()
    call php_refactoring_toolbox#usage#increment('PhpInlineVariable')

    call php_refactoring_toolbox#inline_variable#execute()
endfunction

call php_refactoring_toolbox#vim#end_script()
