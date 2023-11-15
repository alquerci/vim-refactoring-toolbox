call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#rename_directory#adaptors#vim_texteditor#make()
    return s:self
endfunction

let s:self = #{}

function s:self.getCurrentDirectory()
    return substitute(expand('%'), '/[^/]\+$', '', '')
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
