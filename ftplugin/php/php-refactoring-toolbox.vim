if exists("b:did_ftplugin_php_refactoring_toolbox")
  finish
endif
let b:did_ftplugin_php_refactoring_toolbox = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim

function s:registerMappings()
    if s:mappingIsEnabled()
        call s:addNormalMapping(
            \ '<Plug>php_refactoring_toolbox_php_RenameVariable',
            \ '<LocalLeader>rv',
            \ '<SID>renameVariable()'
        \ )

        call s:addNormalMapping(
            \ '<Plug>php_refactoring_toolbox_php_RenameProperty',
            \ '<LocalLeader>rp',
            \ '<SID>renameProperty()'
        \ )
    endif
endfunction

function s:mappingIsEnabled()
    return !exists('no_plugin_maps') && !exists('no_php_maps')
endfunction

function s:renameVariable() " {{{
    call php_refactoring_toolbox#usage#increment('PhpRenameVariable')

    call php_refactoring_toolbox#rename_variable#execute(php_refactoring_toolbox#input#make())
endfunction

function s:renameProperty() " {{{
    call php_refactoring_toolbox#usage#increment('PhpRenameProperty')

    call php_refactoring_toolbox#rename_property#execute(php_refactoring_toolbox#input#make())
endfunction

function s:addNormalMapping(name, keys, executeFunction)
    if !hasmapto(a:name)
        execute 'nmap <buffer> <unique> '.a:keys.' '.a:name
    endif

    execute 'nnoremap <script> <buffer> <unique> '.a:name.' :call '.a:executeFunction.'<Enter>'
endfunction

call s:registerMappings()

let s:save_cpoptions = &cpoptions
set cpoptions&vim
