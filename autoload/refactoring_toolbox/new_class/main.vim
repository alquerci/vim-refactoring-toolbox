call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#new_class#main#execute()
    call refactoring_toolbox#usage#increment('PhpNewClass')

    call refactoring_toolbox#new_class#execute(
        \ refactoring_toolbox#adaptor#phpactor#make()
    \ )
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
