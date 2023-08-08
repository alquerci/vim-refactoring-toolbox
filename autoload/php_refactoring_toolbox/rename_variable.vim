let s:php_regex_func_line = php_refactoring_toolbox#regex#func_line
let s:regex_after_word_boundary = php_refactoring_toolbox#regex#after_word_boudary
let s:regex_case_sensitive = php_refactoring_toolbox#regex#case_sensitive
let s:SEARCH_NOT_FOUND = 0

function! php_refactoring_toolbox#rename_variable#execute()
    let l:oldName = s:readNameOnCurrentPosition()
    let l:newName = s:askForNewName(l:oldName)

    if s:shouldAskUserToValidateRename()
        try
            call s:askForConfirmationWhenNewNameAlreadyExists(l:newName)
        catch /already_exists/
            return
        endtry
    endif

    call s:replaceVariableName(l:oldName, '$'.l:newName)
endfunction

function! s:readNameOnCurrentPosition()
    return substitute(expand('<cword>'), '^\$*', '', '')
endfunction

function! s:askForNewName(oldName)
    return input('Rename ' . a:oldName . ' to: ', a:oldName)
endfunction

function! s:shouldAskUserToValidateRename()
    return g:vim_php_refactoring_auto_validate_rename == 0
endfunction

function! s:askForConfirmationWhenNewNameAlreadyExists(newName)
    if s:newNameAlreadyExists(a:newName)
        call s:echoError('$' . a:newName . ' seems to already exist in the current function scope. Rename anyway ?')
        if inputlist(["0. No", "1. Yes"]) == 0
            throw 'already_exists'
        endif
    endif
endfunction

function! s:newNameAlreadyExists(newName)
    let l:variablePattern = s:makeVariablePattern(a:newName)

    return s:searchInCurrentFunction(l:variablePattern) != s:SEARCH_NOT_FOUND
endfunction

function! s:searchInCurrentFunction(pattern)
    let [l:startLine, l:stopLine] = s:findCurrentFunctionLineRange()

    return s:searchInRange(a:pattern, l:startLine, l:stopLine)
endfunction

function! s:findCurrentFunctionLineRange()
    let l:backupPosition = getcurpos()

    call search(s:php_regex_func_line, 'beW')
    let l:startLine = line('.')

    call search('{', 'W')
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

function! s:replaceVariableName(oldName, newName)
    let l:variablePattern = s:makeVariablePattern(a:oldName)

    call s:replaceInCurrentFunction(l:variablePattern, a:newName)
endfunction

function! s:makeVariablePattern(variableName)
    return s:regex_case_sensitive.'$'.a:variableName.s:regex_after_word_boundary
endfunction

function! s:replaceInCurrentFunction(search, replace)
    let l:backupPosition = getcurpos()

    let [l:startLine, l:stopLine] = s:findCurrentFunctionLineRange()

    exec l:startLine . ',' . l:stopLine . ':s/' . a:search . '/'. a:replace .'/ge'

    call setpos('.', l:backupPosition)
endfunction
