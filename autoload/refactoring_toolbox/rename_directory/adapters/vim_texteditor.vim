call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#rename_directory#adapters#vim_texteditor#make()
    return s:self
endfunction

let s:self = #{}

function s:self.getCurrentDirectory()
    return substitute(expand('%'), '/[^/]\+$', '', '')
endfunction

call refactoring_toolbox#adapters#vim#end_script()
