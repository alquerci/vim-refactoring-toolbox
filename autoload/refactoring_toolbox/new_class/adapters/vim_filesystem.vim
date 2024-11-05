call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#new_class#adapters#vim_filesystem#make()
    return s:self
endfunction

let s:self = #{}

function s:self.writeFileWithLines(filepath, lines)
    call writefile(a:lines, a:filepath)
endfunction

function s:self.filepathExists(filepath)
    return filereadable(a:filepath) || isdirectory(a:filepath)
endfunction

call refactoring_toolbox#adapters#vim#end_script()
