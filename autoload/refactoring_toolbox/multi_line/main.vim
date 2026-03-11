call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#multi_line#main#multiLineForPhp()
    call refactoring_toolbox#usage#increment('PhpMultiLine')

    let l:multiliner = refactoring_toolbox#multi_line#multiliner#construct()

    call l:multiliner.execute()
endfunction

call refactoring_toolbox#adapters#vim#end_script()
