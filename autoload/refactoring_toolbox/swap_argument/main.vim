call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#swap_argument#main#swapArgumentForPhp()
    call refactoring_toolbox#usage#increment('PhpSwapArgument')

    let l:swapper = refactoring_toolbox#swap_argument#argument_swapper#construct(
        \ refactoring_toolbox#adapters#vim_texteditor#construct()
    \ )

    call l:swapper.execute()
endfunction

call refactoring_toolbox#adapters#vim#end_script()
