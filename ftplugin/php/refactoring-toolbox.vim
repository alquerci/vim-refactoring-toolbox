try
    call refactoring_toolbox#adaptor#vim#begin_ftplugin('refactoring_toolbox')
catch /plugin_loaded/
    finish
endtry

function s:registerMappings()
    if s:mappingIsEnabled()
        call s:addBufferNormalMapping(
            \ '<LocalLeader>nc',
            \ '<Plug>refactoring_toolbox_php_NewClass',
            \ 'refactoring_toolbox#new_class#main#execute()'
        \ )

        call s:addBufferVisualMapping(
            \ '<LocalLeader>em',
            \ '<Plug>refactoring_toolbox_php_ExtractMethod',
            \ 'refactoring_toolbox#extract_method#main#extractMethodForPhp()'
        \ )

        call s:addBufferNormalMapping(
            \ '<LocalLeader>rm',
            \ '<Plug>refactoring_toolbox_php_RenameMethod',
            \ 'refactoring_toolbox#rename_method#main#execute()'
        \ )

        call s:addBufferVisualMapping(
            \ '<LOcalLeader>ev',
            \ '<Plug>refactoring_toolbox_php_ExtractVariable',
            \ 'refactoring_toolbox#extract_variable#main#execute()'
        \ )

        call s:addBufferNormalMapping(
            \ '<LocalLeader>rv',
            \ '<Plug>refactoring_toolbox_php_RenameVariable',
            \ 'refactoring_toolbox#rename_variable#main#execute()'
        \ )

        call s:addBufferNormalMapping(
            \ '<LocalLeader>rlv',
            \ '<Plug>refactoring_toolbox_php_RenameLocalVariable',
            \ 'refactoring_toolbox#rename_variable#main#renameLocalVariable()'
        \ )

        call s:addBufferNormalMapping(
            \ '<LocalLeader>iv',
            \ '<Plug>refactoring_toolbox_php_InlineVariable',
            \ 'refactoring_toolbox#inline_variable#main#execute()'
        \ )

        call s:addBufferNormalMapping(
            \ '<LocalLeader>ep',
            \ '<Plug>refactoring_toolbox_php_ExtractProperty',
            \ 'refactoring_toolbox#extract_property#main#execute()'
        \ )

        call s:addBufferNormalMapping(
            \ '<LocalLeader>rp',
            \ '<Plug>refactoring_toolbox_php_RenameProperty',
            \ 'refactoring_toolbox#rename_property#main#execute()'
        \ )

        call s:addBufferNormalMapping(
            \ '<LocalLeader>rcv',
            \ '<Plug>refactoring_toolbox_php_RenameClassVariable',
            \ 'refactoring_toolbox#rename_property#main#renameClassVariable()'
        \ )

        call s:addBufferNormalMapping(
            \ '<LocalLeader>sg',
            \ '<Plug>refactoring_toolbox_php_SettersAndGetters',
            \ 'refactoring_toolbox#create_getter_and_setter#main#execute()'
        \ )

        call s:addBufferNormalMapping(
            \ '<LocalLeader>cog',
            \ '<Plug>refactoring_toolbox_php_OnlyGetters',
            \ 'refactoring_toolbox#create_getter_and_setter#main#createOnlyGetters()'
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

    call refactoring_toolbox#adaptor#vim#appendFileTypeUndo('nunmap <buffer> '.a:left)
endfunction

function s:addUniqueScriptAndBufferNormalMapping(left, right)
    execute 'nnoremap <script> <buffer> <unique> '.a:left.' '.a:right

    call refactoring_toolbox#adaptor#vim#appendFileTypeUndo('nunmap <script> <buffer> '.a:left)
endfunction

function s:addBufferVisualMapping(keys, name, executeFunction)
    if !hasmapto(a:name, 'v')
        call s:addUniqueBufferVisualMapping(a:keys, a:name)
    endif

    call s:addUniqueScriptAndBufferVisualMapping(a:name, ':call '.a:executeFunction.'<Enter>')
endfunction

function s:addUniqueBufferVisualMapping(left, right)
    execute 'vmap <buffer> <unique> '.a:left.' '.a:right

    call refactoring_toolbox#adaptor#vim#appendFileTypeUndo('vunmap <buffer> '.a:left)
endfunction

function s:addUniqueScriptAndBufferVisualMapping(left, right)
    execute 'vnoremap <script> <buffer> <unique> '.a:left.' '.a:right

    call refactoring_toolbox#adaptor#vim#appendFileTypeUndo('vunmap <script> <buffer> '.a:left)
endfunction

call s:registerMappings()

call refactoring_toolbox#adaptor#vim#end_ftplugin()
