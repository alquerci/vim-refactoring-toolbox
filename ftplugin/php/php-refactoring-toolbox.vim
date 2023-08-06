if exists("b:did_ftplugin_php_refactoring_toolbox")
  finish
endif
let b:did_ftplugin_php_refactoring_toolbox = 1

if !exists("*s:registerMappings")
    function! s:registerMappings()
        if s:mappingIsEnabled()
            call s:addNormalMapping('<Plug>PhpRenameVariable', '<LocalLeader>rv', '<SID>renameVariable()')
            call s:addNormalMapping('<Plug>PhpRenameProperty', '<LocalLeader>rp', '<SID>renameProperty()')
        endif
    endfunction
endif

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

if !exists("*s:renameProperty")
    function! s:renameProperty() " {{{
        call php_refactoring_toolbox#usage#increment('PhpRenameProperty')

        call php_refactoring_toolbox#rename_property#execute()
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

call s:registerMappings()
