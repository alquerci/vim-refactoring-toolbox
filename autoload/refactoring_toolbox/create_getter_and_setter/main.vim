call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#create_getter_and_setter#main#execute()
    call refactoring_toolbox#usage#increment('PhpCreateSettersAndGetters')

    call refactoring_toolbox#create_getter_and_setter#execute(
        \ refactoring_toolbox#adapters#input#make()
    \ )
endfunction

function refactoring_toolbox#create_getter_and_setter#main#createOnlyGetters()
    call refactoring_toolbox#usage#increment('PhpCreateGetters')

    call refactoring_toolbox#create_getter_and_setter#createOnlyGetters(
        \ refactoring_toolbox#adapters#input#make()
    \ )
endfunction

call refactoring_toolbox#adapters#vim#end_script()
