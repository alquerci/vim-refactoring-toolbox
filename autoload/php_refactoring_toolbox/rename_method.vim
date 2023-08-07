let s:php_regex_class_line = php_refactoring_toolbox#regex#class_line
let s:php_regex_func_line = php_refactoring_toolbox#regex#func_line
let s:regex_after_word_boundary = php_refactoring_toolbox#regex#after_word_boudary
let s:php_regex_before_function = '\%(\%('.s:php_regex_func_line.'\)\|$this->\|self::\)\@<='
let s:SEARCH_NO_MATCH = 0

function! php_refactoring_toolbox#rename_method#execute()
    let l:oldName = s:readNameOnCurrentPosition()
    let l:newName = s:askForNewName(l:oldName)

    if s:shouldAskUserToValidateRename()
        try
            call s:askForConfirmationWhenNewNameAlreadyExists(l:newName)
        catch /already_exists/
            return
        endtry
    endif

    call s:replacePropertyName(l:oldName, l:newName)
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
        call s:echoError(a:newName . ' seems to already exist in the current class. Rename anyway ?')
        if inputlist(["0. No", "1. Yes"]) == 0
            throw 'already_exists'
        endif
    endif
endfunction

function! s:newNameAlreadyExists(newName)
    let l:propertyPattern = s:makePropertyPattern(a:newName)

    return s:searchInCurrentClass(l:propertyPattern) != s:SEARCH_NO_MATCH
endfunction

function! s:searchInCurrentClass(pattern)
    let [l:startLine, l:stopLine] = s:findCurrentClassLineRange()

    return s:searchInRange(a:pattern, l:startLine, l:stopLine)
endfunction

function! s:findCurrentClassLineRange()
    let l:backupPosition = getcurpos()

    call search(s:php_regex_class_line, 'beW')
    call search('{', 'W')
    let l:startLine = line('.')
    call searchpair('{', '', '}', 'W')
    let l:stopLine = line('.')

    call setpos('.', l:backupPosition)

    return [l:startLine, l:stopLine]
endfunction

function! s:searchInRange(pattern, startLine, endLine)
    return search('\%>' . a:startLine . 'l\%<' . a:endLine . 'l' . a:pattern, 'n')
endfunction

function! s:echoError(message)
    echohl ErrorMsg
    echomsg a:message
    echohl NONE
endfunction

function! s:replacePropertyName(oldName, newName)
    let l:propertyPattern = s:makePropertyPattern(a:oldName)

    call s:replaceInCurrentClass(l:propertyPattern, a:newName)
endfunction

function! s:makePropertyPattern(propertyName)
    return s:php_regex_before_function.a:propertyName.s:regex_after_word_boundary
endfunction

function! s:replaceInCurrentClass(search, replace)
    let l:backupPosition = getcurpos()

    let [l:startLine, l:stopLine] = s:findCurrentClassLineRange()

    exec l:startLine . ',' . l:stopLine . ':s/' . a:search . '/'. a:replace .'/ge'

    call setpos('.', l:backupPosition)
endfunction