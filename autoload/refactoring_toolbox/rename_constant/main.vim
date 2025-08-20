call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#rename_constant#main#renameConstantForPhp()
    call refactoring_toolbox#usage#increment('PhpRenameConstant')

    call refactoring_toolbox#rename_constant#constant_renamer#execute(
        \ refactoring_toolbox#adapters#input#make(),
        \ refactoring_toolbox#adapters#output#make(),
        \ refactoring_toolbox#adapters#vim_texteditor#construct(),
        \ refactoring_toolbox#rename_constant#adapters#php_language#construct(),
    \ )
endfunction

call refactoring_toolbox#adapters#vim#end_script()
