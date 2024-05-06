call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#extract_constant#adapters#vim_texteditor#make()
    let l:this = #{}

    call extend(l:this, refactoring_toolbox#adapters#vim_texteditor#make())
    call extend(l:this, s:self)

    return l:this
endfunction

let s:self = #{}

function s:self.isInVisualBlockMode()
    return visualmode() == ''
endfunction

function s:self.isInVisualLineMode()
    return visualmode() == 'V'
endfunction

call refactoring_toolbox#adapters#vim#end_script()
