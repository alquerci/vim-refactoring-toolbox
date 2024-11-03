let s:texteditor = refactoring_toolbox#rename_directory#adapters#vim_texteditor#make()

call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#rename_directory#adapters#texteditor_factory#make()
    return s:texteditor
endfunction

function refactoring_toolbox#rename_directory#adapters#texteditor_factory#setTextEditor(texteditor)
    let s:texteditor = a:texteditor
endfunction

call refactoring_toolbox#adapters#vim#end_script()
