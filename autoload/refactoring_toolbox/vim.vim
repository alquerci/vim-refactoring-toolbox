function refactoring_toolbox#vim#begin_ftplugin(name)
    call s:checkFileTypePluginIsLoadedOnce(a:name)

    call refactoring_toolbox#vim#begin_script()
endfunction

function refactoring_toolbox#vim#end_ftplugin()
    call refactoring_toolbox#vim#end_script()
endfunction

function refactoring_toolbox#vim#begin_plugin(name)
    call s:checkPluginIsLoadedOnce(a:name)

    call refactoring_toolbox#vim#begin_script()
endfunction

function refactoring_toolbox#vim#end_plugin()
    call refactoring_toolbox#vim#end_script()
endfunction

function refactoring_toolbox#vim#begin_script()
    call s:configureCompatibilityOptions()
endfunction

function refactoring_toolbox#vim#end_script()
    call s:restoreCompatibilityOptions()
endfunction

function refactoring_toolbox#vim#appendFileTypeUndo(script)
    let l:scriptWithTry = 'try|'.a:script.'|catch|endtry'

    if !exists('b:undo_ftplugin')
        let b:undo_ftplugin = l:scriptWithTry
    else
        let b:undo_ftplugin .= '|'.l:scriptWithTry
    endif
endfunction

function s:checkFileTypePluginIsLoadedOnce(name)
    if exists('b:did_ftplugin_'.a:name)
        throw 'plugin_loaded'
    endif

    let b:did_ftplugin_{a:name} = 1

    call refactoring_toolbox#vim#appendFileTypeUndo('unlet! b:did_ftplugin_'.a:name)
endfunction

function s:checkPluginIsLoadedOnce(name)
    if exists('g:loaded_'.a:name)
        throw 'plugin_loaded'
    endif

    let g:loaded_{a:name} = 1
endfunction

function s:configureCompatibilityOptions()
    call s:backupCompatibilityOptions()

    call s:allowLineContinuation()
endfunction

function s:backupCompatibilityOptions()
    let s:save_cpoptions = &cpoptions
endfunction

function s:allowLineContinuation()
    set cpoptions-=C
endfunction

function s:restoreCompatibilityOptions()
    let &cpoptions = s:save_cpoptions
    unlet s:save_cpoptions
endfunction
