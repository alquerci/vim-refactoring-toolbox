if exists("b:did_ftplugin_php_refactoring_toolbox")
  finish
endif
let b:did_ftplugin_php_refactoring_toolbox = 1

if !exists("*s:mappingIsEnabled")
    function! s:mappingIsEnabled()
        return !exists('no_plugin_maps') && !exists('no_php_maps')
    endfunction
endif

if !exists("*s:renameVariable")
    function! s:renameVariable() " {{{
        call php_refactoring_toolbox#usage#increment('PhpRenameVariable')

        call php_refactoring_toolbox#rename_variable#execute()
    endfunction
endif

if !exists("*s:addNormalMapping")
    function! s:addNormalMapping(name, keys, executeFunction)
        if !hasmapto(a:name)
            execute 'nmap <buffer> <unique> '.a:keys.' '.a:name
        endif

        execute 'nnoremap <buffer> <unique> '.a:name.' :call '.a:executeFunction.'<Enter>'
    endfunction
endif

if s:mappingIsEnabled()
    call s:addNormalMapping('<Plug>PhpRenameVariable', '<LocalLeader>rv', '<SID>renameVariable()')
endif
