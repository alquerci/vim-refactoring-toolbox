try
    call php_refactoring_toolbox#vim#begin_ftplugin('php_refactoring_toolbox')
catch /plugin_loaded/
    finish
endtry

function s:registerMappings()
    if s:mappingIsEnabled()
        call s:addBufferVisualMapping(
            \ '<LocalLeader>em',
            \ '<Plug>php_refactoring_toolbox_php_ExtractMethod',
            \ 'php_refactoring_toolbox#extract_method#main#execute()'
        \ )

        call s:addBufferNormalMapping(
            \ '<LocalLeader>rm',
            \ '<Plug>php_refactoring_toolbox_php_RenameMethod',
            \ 'php_refactoring_toolbox#rename_method#main#execute()'
        \ )

        call s:addBufferVisualMapping(
            \ '<LOcalLeader>ev',
            \ '<Plug>php_refactoring_toolbox_php_ExtractVariable',
            \ 'php_refactoring_toolbox#extract_variable#main#execute()'
        \ )

        call s:addBufferNormalMapping(
            \ '<LocalLeader>rv',
            \ '<Plug>php_refactoring_toolbox_php_RenameVariable',
            \ 'php_refactoring_toolbox#rename_variable#main#execute()'
        \ )

        call s:addBufferNormalMapping(
            \ '<LocalLeader>rlv',
            \ '<Plug>php_refactoring_toolbox_php_RenameLocalVariable',
            \ 'php_refactoring_toolbox#rename_variable#main#renameLocalVariable()'
        \ )

        call s:addBufferNormalMapping(
            \ '<LocalLeader>iv',
            \ '<Plug>php_refactoring_toolbox_php_InlineVariable',
            \ 'php_refactoring_toolbox#inline_variable#main#execute()'
        \ )

        call s:addBufferNormalMapping(
            \ '<LocalLeader>rp',
            \ '<Plug>php_refactoring_toolbox_php_RenameProperty',
            \ 'php_refactoring_toolbox#rename_property#main#execute()'
        \ )

        call s:addBufferNormalMapping(
            \ '<LocalLeader>rcv',
            \ '<Plug>php_refactoring_toolbox_php_RenameClassVariable',
            \ 'php_refactoring_toolbox#rename_property#main#renameClassVariable()'
        \ )

        call s:addBufferNormalMapping(
            \ '<LocalLeader>sg',
            \ '<Plug>php_refactoring_toolbox_php_SettersAndGetters',
            \ 'php_refactoring_toolbox#create_getter_and_setter#main#execute()'
        \ )

        call s:addBufferNormalMapping(
            \ '<LocalLeader>cog',
            \ '<Plug>php_refactoring_toolbox_php_OnlyGetters',
            \ 'php_refactoring_toolbox#create_getter_and_setter#main#createOnlyGetters()'
        \ )
    endif
endfunction

function s:mappingIsEnabled()
    return !exists('no_plugin_maps') && !exists('no_php_maps')
endfunction

function s:addBufferNormalMapping(keys, name, executeFunction)
    if !hasmapto(a:name, 'n')
        call s:addUniqueBufferNormalMapping(a:keys, a:name)
    endif

    call s:addUniqueScriptAndBufferNormalMapping(a:name, ':call '.a:executeFunction.'<Enter>')
endfunction

function s:addUniqueBufferNormalMapping(left, right)
    execute 'nmap <buffer> <unique> '.a:left.' '.a:right

    call php_refactoring_toolbox#vim#appendFileTypeUndo('nunmap <buffer> '.a:left)
endfunction

function s:addUniqueScriptAndBufferNormalMapping(left, right)
    execute 'nnoremap <script> <buffer> <unique> '.a:left.' '.a:right

    call php_refactoring_toolbox#vim#appendFileTypeUndo('nunmap <script> <buffer> '.a:left)
endfunction

function s:addBufferVisualMapping(keys, name, executeFunction)
    if !hasmapto(a:name, 'v')
        call s:addUniqueBufferVisualMapping(a:keys, a:name)
    endif

    call s:addUniqueScriptAndBufferVisualMapping(a:name, ':call '.a:executeFunction.'<Enter>')
endfunction

function s:addUniqueBufferVisualMapping(left, right)
    execute 'vmap <buffer> <unique> '.a:left.' '.a:right

    call php_refactoring_toolbox#vim#appendFileTypeUndo('vunmap <buffer> '.a:left)
endfunction

function s:addUniqueScriptAndBufferVisualMapping(left, right)
    execute 'vnoremap <script> <buffer> <unique> '.a:left.' '.a:right

    call php_refactoring_toolbox#vim#appendFileTypeUndo('vunmap <script> <buffer> '.a:left)
endfunction

call s:registerMappings()

call php_refactoring_toolbox#vim#end_ftplugin()
