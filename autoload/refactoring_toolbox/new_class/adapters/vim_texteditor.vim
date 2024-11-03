call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#new_class#adapters#vim_texteditor#make()
    return s:self
endfunction

let s:self = #{}

function s:self.getCurrentFileDirectory()
    return expand('%:p:h')
endfunction

function s:self.getCurrentFilePath()
    return expand('%:p')
endfunction

function s:self.getWordOnCursor()
    return expand('<cword>')
endfunction

function s:self.openFileAside(filepath)
    call s:moveToNewWindowAside()

    call s:openFileOnCurrentWindow(a:filepath)

    call s:backToPreviousWindow()
endfunction

function s:moveToNewWindowAside()
    execute 'vertical new'
endfunction

function s:openFileOnCurrentWindow(filepath)
    execute 'edit '.fnameescape(a:filepath)
endfunction

function s:backToPreviousWindow()
    wincmd p
endfunction

call refactoring_toolbox#adapters#vim#end_script()
