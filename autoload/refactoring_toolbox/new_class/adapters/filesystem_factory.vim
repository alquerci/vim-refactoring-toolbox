let s:filesystem = refactoring_toolbox#new_class#adapters#vim_filesystem#make()

call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#new_class#adapters#filesystem_factory#make()
    return s:filesystem
endfunction

function refactoring_toolbox#new_class#adapters#filesystem_factory#setFilesystem(filesystem)
    let s:filesystem = a:filesystem
endfunction

call refactoring_toolbox#adapters#vim#end_script()
