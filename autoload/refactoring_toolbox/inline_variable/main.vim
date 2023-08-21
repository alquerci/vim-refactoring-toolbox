call refactoring_toolbox#vim#begin_script()

function refactoring_toolbox#inline_variable#main#execute()
    call refactoring_toolbox#usage#increment('PhpInlineVariable')

    call refactoring_toolbox#inline_variable#execute()
endfunction

call refactoring_toolbox#vim#end_script()
