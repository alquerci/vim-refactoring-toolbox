call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#extract_constant#adaptor#vim_texteditor#make()
    return s:self
endfunction

let s:self = #{}

function s:self.isInVisualBlockMode()
    return visualmode() == ''
endfunction

function s:self.isInVisualLineMode()
    return visualmode() == 'V'
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
