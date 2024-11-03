call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#new_class#main#execute()
    call refactoring_toolbox#usage#increment('PhpNewClass')

    call refactoring_toolbox#new_class#class_maker#executeForPhp(
        \ refactoring_toolbox#adapters#phpactor#make(),
        \ refactoring_toolbox#new_class#adapters#texteditor_factory#make(),
    \ )
endfunction

function refactoring_toolbox#new_class#main#executeForTypescript()
    call refactoring_toolbox#usage#increment('TsNewClass')

    call refactoring_toolbox#new_class#class_maker#execute(
        \ refactoring_toolbox#new_class#adapters#filesystem_factory#make(),
        \ refactoring_toolbox#new_class#adapters#texteditor_factory#make(),
        \ refactoring_toolbox#new_class#adapters#ts_language#make(),
    \ )
endfunction

call refactoring_toolbox#adapters#vim#end_script()
