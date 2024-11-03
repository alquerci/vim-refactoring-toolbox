let s:LIST_ITEM_NOT_FOUND = -1

call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#new_class#adapters#spy_filesystem#make()
    return s:constuct()
endfunction

function refactoring_toolbox#new_class#adapters#spy_filesystem#get()
    if s:constructed
        return s:self
    else
        return s:constuct()
    endif
endfunction

let s:self = #{}
let s:constructed = v:false

function s:constuct()
    let s:self.writtenFiles = []
    let s:self.writtenLines = []

    let s:constructed = v:true

    return s:self
endfunction

function s:self.writeFileWithLines(filepath, lines)
    call add(s:self.writtenFiles, a:filepath)
    call add(s:self.writtenLines, a:lines)
endfunction

function s:self.fileWasWritten(filepath)
    return s:LIST_ITEM_NOT_FOUND != s:findFileIndex(a:filepath)
endfunction

function s:self.writtenLinesOnFilepath(filepath)
    return s:self.writtenLines[s:findFileIndex(a:filepath)]
endfunction

function s:findFileIndex(filepath)
    return index(s:self.writtenFiles, a:filepath)
endfunction

call refactoring_toolbox#adapters#vim#end_script()
