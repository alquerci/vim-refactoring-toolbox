call refactoring_toolbox#adapters#vim#begin_script()

function! refactoring_toolbox#new_class#execute(phpactor)
    let s:phpactor = a:phpactor
    let l:newClassName = expand('<cword>')

    call s:makeClass(s:getCurrentFilePath(), s:getFilePathOfNewClassNamed(l:newClassName))
endfunction

function s:getCurrentFilePath()
    return expand('%:p')
endfunction

function s:getFilePathOfNewClassNamed(className)
    return expand('%:p:h')."/".a:className.'.php'
endfunction

function! s:makeClass(currentFilePath, newClassFilePath)
    call s:phpactor.rpc("class_new", {
        \ "current_path": a:currentFilePath,
        \ "new_path": a:newClassFilePath,
        \ "variant": "default"
    \ })
endfunction

call refactoring_toolbox#adapters#vim#end_script()
