call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#rename_directory#adapters#stub_texteditor#make()
    return s:self
endfunction

let s:self = #{
    \ currentFileDirectory: v:null
\ }

function s:self.getCurrentFileDirectory()
    return s:self.currentFileDirectory
endfunction

function s:self.setCurrentFileDirectory(directory)
    let s:self.currentFileDirectory = a:directory
endfunction

call refactoring_toolbox#adapters#vim#end_script()
