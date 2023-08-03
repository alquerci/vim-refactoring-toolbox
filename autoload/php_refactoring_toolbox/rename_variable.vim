let s:php_regex_func_line = php_refactoring_toolbox#regex#func_line

function! php_refactoring_toolbox#rename_variable#execute()
    let l:oldName = substitute(expand('<cword>'), '^\$*', '', '')
    let l:newName = inputdialog('Rename ' . l:oldName . ' to: ')

    if g:vim_php_refactoring_auto_validate_rename == 0
        if s:PhpSearchInCurrentFunction('\C$' . l:newName . '\>', 'n') > 0
            call s:echoError('$' . l:newName . ' seems to already exist in the current function scope. Rename anyway ?')
            if inputlist(["0. No", "1. Yes"]) == 0
                return
            endif
        endif
    endif

    call s:PhpReplaceInCurrentFunction('\C$' . l:oldName . '\>', '$' . l:newName)
endfunction

function! s:PhpSearchInCurrentFunction(pattern, flags) " {{{
    normal! mr
    call search(s:php_regex_func_line, 'bW')
    let l:startLine = line('.')
    call search('{', 'W')
    exec "normal! %"
    let l:stopLine = line('.')
    normal! `r
    return s:PhpSearchInRange(a:pattern, a:flags, l:startLine, l:stopLine)
endfunction
" }}}

function! s:PhpSearchInRange(pattern, flags, startLine, endLine) " {{{
    return search('\%>' . a:startLine . 'l\%<' . a:endLine . 'l' . a:pattern, a:flags)
endfunction
" }}}

function! s:PhpReplaceInCurrentFunction(search, replace) " {{{
    normal! mr

    call search(s:php_regex_func_line, 'bW')
    let l:startLine = line('.')

    call search('{', 'W')
    call searchpair('{', '', '}', 'W')
    let l:stopLine = line('.')

    exec l:startLine . ',' . l:stopLine . ':s/' . a:search . '/'. a:replace .'/ge'
    normal! `r
endfunction
" }}}

function! s:echoError(message)
    echohl ErrorMsg
    echomsg a:message
    echohl NONE
endfunction
