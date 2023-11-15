call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#rename_directory#adaptors#spy_texteditor#make()
    return s:self
endfunction

let s:self = #{
    \ currentDirectory: v:null
\ }

function s:self.getCurrentDirectory()
    return s:self.currentDirectory
endfunction

function s:self.setCurrentDirectory(directory)
    let s:self.currentDirectory = a:directory
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
