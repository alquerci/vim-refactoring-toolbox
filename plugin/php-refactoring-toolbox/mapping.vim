if exists('g:loaded_php_refactoring_toolbox_mapping')
    finish
endif
let g:loaded_php_refactoring_toolbox_mapping = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim

function s:main()
    call s:addVisualMapping(
        \ '<Plug>php_refactoring_toolbox_ExtractMethod',
        \ '<Leader>em',
        \ '<SID>extractMethod()'
    \ )

    call s:addNormalMapping(
        \ '<Plug>php_refactoring_toolbox_RenameMethod',
        \ '<Leader>rm',
        \ '<SID>renameMethod()'
    \ )

    call s:addVisualMapping(
        \ '<Plug>php_refactoring_toolbox_ExtractVariable',
        \ '<Leader>ev',
        \ '<SID>extractVariable()'
    \ )

    call s:addNormalMapping(
        \ '<Plug>php_refactoring_toolbox_RenameVariable',
        \ '<Leader>rlv',
        \ '<SID>renameVariable()'
    \ )

    call s:addNormalMapping(
        \ '<Plug>php_refactoring_toolbox_InlineVariable',
        \ '<Leader>iv',
        \ '<SID>inlineVariable()'
    \ )

    call s:addNormalMapping(
        \ '<Plug>php_refactoring_toolbox_RenameProperty',
        \ '<Leader>rcv',
        \ '<SID>renameProperty()'
    \ )

    call s:addNormalMapping(
        \ '<Plug>php_refactoring_toolbox_RenameDirectory',
        \ '<Leader>rd',
        \ '<SID>renameDirectory()'
    \ )

    call s:addNormalMapping(
        \ '<Plug>php_refactoring_toolbox_CreateSettersAndGetters',
        \ '<Leader>sg',
        \ '<SID>createSettersAndGetters()'
    \ )

    call s:addNormalMapping(
        \ '<Plug>php_refactoring_toolbox_CreateGetters',
        \ '<Leader>cog',
        \ '<SID>createGetters()'
    \ )
endfunction

function s:extractMethod() range
    call php_refactoring_toolbox#usage#increment('PhpExtractMethod')

    call php_refactoring_toolbox#extract_method#execute(
        \ php_refactoring_toolbox#input#make()
    \ )
endfunction

function s:renameMethod()
    call php_refactoring_toolbox#usage#increment('PhpRenameMethod')

    call php_refactoring_toolbox#rename_method#execute(
        \ php_refactoring_toolbox#input#make()
    \ )
endfunction

function s:extractVariable() range
    call php_refactoring_toolbox#usage#increment('PhpExtractVariable')

    call php_refactoring_toolbox#extract_variable#execute(
        \ php_refactoring_toolbox#input#make()
    \ )
endfunction

function s:renameVariable()
    call php_refactoring_toolbox#usage#increment('PhpRenameLocalVariable')

    call php_refactoring_toolbox#rename_variable#execute(
        \ php_refactoring_toolbox#input#make()
    \ )
endfunction

function s:inlineVariable()
    call php_refactoring_toolbox#usage#increment('PhpInlineVariable')

    call php_refactoring_toolbox#inline_variable#execute()
endfunction

function s:renameProperty()
    call php_refactoring_toolbox#usage#increment('PhpRenameClassVariable')

    call php_refactoring_toolbox#rename_property#execute(
        \ php_refactoring_toolbox#input#make()
    \ )
endfunction

function s:renameDirectory()
    call php_refactoring_toolbox#usage#increment('PhpRenameDirectory')

    call php_refactoring_toolbox#rename_directory#execute(
        \ php_refactoring_toolbox#input#make()
    \ )
endfunction

function s:createSettersAndGetters()
    call php_refactoring_toolbox#usage#increment('PhpCreateSettersAndGetters')

    call php_refactoring_toolbox#create_getter_and_setter#execute(
        \ php_refactoring_toolbox#input#make()
    \ )
endfunction

function s:createGetters()
    call php_refactoring_toolbox#usage#increment('PhpCreateGetters')

    call php_refactoring_toolbox#create_getter_and_setter#createOnlyGetters(
        \ php_refactoring_toolbox#input#make()
    \ )
endfunction

function s:addVisualMapping(name, keys, executeFunction)
    if !hasmapto(a:name)
        execute 'vmap <unique> '.a:keys.' '.a:name
    endif

    execute 'vnoremap <unique> <script> '.a:name.' :call '.a:executeFunction.'<Enter>'
endfunction

function s:addNormalMapping(name, keys, executeFunction)
    if !hasmapto(a:name)
        execute 'nmap <unique> '.a:keys.' '.a:name
    endif

    execute 'nnoremap <unique> <script> '.a:name.' :call '.a:executeFunction.'<Enter>'
endfunction

call s:main()

let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
