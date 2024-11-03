call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#new_class#adapters#stub_texteditor#makeWithCurrentFileDirectory(currentFileDirectory)
    let s:currentFileDirectory = a:currentFileDirectory

    return s:self
endfunction

let s:self = #{}

function s:self.getCurrentFileDirectory()
    return s:currentFileDirectory
endfunction

function s:self.getWordOnCursor()
    return expand('<cword>')
endfunction

function s:self.openFileAside(filepath)
endfunction

call refactoring_toolbox#adapters#vim#end_script()
