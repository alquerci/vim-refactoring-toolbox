let s:php_regex_class_line = php_refactoring_toolbox#regex#class_line

function! php_refactoring_toolbox#rename_property#execute()
    let l:oldName = s:readNameOnCurrentPosition()
    let l:newName = s:askForNewName(l:oldName)

    if s:shouldAskUserToValidateRename()
        try
            call s:askForConfirmationWhenNewNameAlreadyExists(l:newName)
        catch /already_exists/
            return
        endtry
    endif

    call s:phpReplaceInCurrentClass('\C\%(\%(\%(public\|protected\|private\|static\)\%(\_s\+?\?[\\|_A-Za-z0-9]\+\)\?\_s\+\)\+\$\|$this->\)\@<=' . l:oldName . '\>', l:newName)
endfunction

function! s:readNameOnCurrentPosition()
    return substitute(expand('<cword>'), '^\$*', '', '')
endfunction

function! s:askForNewName(oldName)
    return inputdialog('Rename ' . a:oldName . ' to: ')
endfunction

function! s:shouldAskUserToValidateRename()
    return g:vim_php_refactoring_auto_validate_rename == 0
endfunction

function! s:askForConfirmationWhenNewNameAlreadyExists(newName)
    if s:newNameAlreadyExists(a:newName)
        call s:phpEchoError(a:newName . ' seems to already exist in the current class. Rename anyway ?')
        if inputlist(["0. No", "1. Yes"]) == 0
            throw 'already_exists'
        endif
    endif
endfunction

function! s:newNameAlreadyExists(newName)
    return s:phpSearchInCurrentClass('\C\%(\%(\%(public\|protected\|private\|static\)\%(\_s\+?\?[\\|_A-Za-z0-9]\+\)\?\_s\+\)\+\$\|$this->\)\@<=' . a:newName . '\>', 'n') > 0
endfunction

function! s:phpSearchInCurrentClass(pattern, flags)
    normal! mr
    call search(s:php_regex_class_line, 'beW')
    call search('{', 'W')
    let l:startLine = line('.')
    exec "normal! %"
    let l:stopLine = line('.')
    normal! `r
    return s:PhpSearchInRange(a:pattern, a:flags, l:startLine, l:stopLine)
endfunction

function! s:PhpSearchInRange(pattern, flags, startLine, endLine)
    return search('\%>' . a:startLine . 'l\%<' . a:endLine . 'l' . a:pattern, a:flags)
endfunction

function! s:phpEchoError(message)
    echohl ErrorMsg
    echomsg a:message
    echohl NONE
endfunction

function! s:phpReplaceInCurrentClass(search, replace)
    normal! mr

    call search(s:php_regex_class_line, 'beW')
    call search('{', 'W')
    let l:startLine = line('.')
    call searchpair('{', '', '}', 'W')
    let l:stopLine = line('.')

    exec l:startLine . ',' . l:stopLine . ':s/' . a:search . '/'. a:replace .'/ge'
    normal! `r
endfunction
