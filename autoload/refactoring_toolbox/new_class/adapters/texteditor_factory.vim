let s:texteditor = refactoring_toolbox#new_class#adapters#vim_texteditor#make()

call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#new_class#adapters#texteditor_factory#make()
    return s:texteditor
endfunction

function refactoring_toolbox#new_class#adapters#texteditor_factory#setTexteditor(texteditor)
    let s:texteditor = a:texteditor
endfunction

call refactoring_toolbox#adapters#vim#end_script()
