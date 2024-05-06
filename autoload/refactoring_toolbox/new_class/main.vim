call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#new_class#main#execute()
    call refactoring_toolbox#usage#increment('PhpNewClass')

    call refactoring_toolbox#new_class#execute(
        \ refactoring_toolbox#adapters#phpactor#make()
    \ )
endfunction

call refactoring_toolbox#adapters#vim#end_script()
