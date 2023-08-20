call php_refactoring_toolbox#vim#begin_script()

function php_refactoring_toolbox#create_getter_and_setter#main#execute()
    call php_refactoring_toolbox#usage#increment('PhpCreateSettersAndGetters')

    call php_refactoring_toolbox#create_getter_and_setter#execute(
        \ php_refactoring_toolbox#input#make()
    \ )
endfunction

function php_refactoring_toolbox#create_getter_and_setter#main#createOnlyGetters()
    call php_refactoring_toolbox#usage#increment('PhpCreateGetters')

    call php_refactoring_toolbox#create_getter_and_setter#createOnlyGetters(
        \ php_refactoring_toolbox#input#make()
    \ )
endfunction

call php_refactoring_toolbox#vim#end_script()
