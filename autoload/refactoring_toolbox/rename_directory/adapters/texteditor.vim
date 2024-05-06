call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#rename_directory#adapters#texteditor#make()
    return refactoring_toolbox#rename_directory#adapters#vim_texteditor#make()
endfunction

call refactoring_toolbox#adapters#vim#end_script()
