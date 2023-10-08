call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#inline_variable#main#execute()
    call refactoring_toolbox#usage#increment('PhpInlineVariable')

    call refactoring_toolbox#inline_variable#execute()
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
