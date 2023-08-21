try
    call refactoring_toolbox#vim#begin_plugin('refactoring_toolbox_mappings')
catch /plugin_loaded/
    finish
endtry

function s:main()
    call s:addNormalMapping(
        \ '<Leader>rd',
        \ '<Plug>refactoring_toolbox_RenameDirectory',
        \ 'refactoring_toolbox#rename_directory#main#execute()'
    \ )
endfunction

function s:addVisualMapping(keys, name, executeFunction)
    if !hasmapto(a:name, 'v')
        execute 'vmap <unique> '.a:keys.' '.a:name
    endif

    execute 'vnoremap <unique> <script> '.a:name.' :call '.a:executeFunction.'<Enter>'
endfunction

function s:addNormalMapping(keys, name, executeFunction)
    if !hasmapto(a:name, 'n')
        execute 'nmap <unique> '.a:keys.' '.a:name
    endif

    execute 'nnoremap <unique> <script> '.a:name.' :call '.a:executeFunction.'<Enter>'
endfunction

call s:main()

call refactoring_toolbox#vim#end_plugin()
