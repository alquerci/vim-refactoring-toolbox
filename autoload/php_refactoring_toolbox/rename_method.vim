let s:php_regex_class_line = php_refactoring_toolbox#regex#class_line
let s:php_regex_func_line = php_refactoring_toolbox#regex#func_line
let s:regex_after_word_boundary = php_refactoring_toolbox#regex#after_word_boudary
let s:php_regex_before_function = '\%(\%('.s:php_regex_func_line.'\)\|$this->\|self::\)\@<='
let s:SEARCH_NO_MATCH = 0

function! php_refactoring_toolbox#rename_method#execute(input)
    let s:input = a:input

    let l:oldName = s:readNameOnCurrentPosition()
    let l:newName = s:askForNewName(l:oldName)

    if s:canRenameMethodTo(l:newName)
        call s:renameMethodName(l:oldName, l:newName)
    endif
endfunction

function! s:readNameOnCurrentPosition()
    return substitute(expand('<cword>'), '^\$*', '', '')
endfunction

function! s:askForNewName(oldName)
    return s:input.askQuestionWithProposedAnswer('Rename '.a:oldName.' to:', a:oldName)
endfunction

function s:canRenameMethodTo(newName)
    if s:shouldAskUserToValidateRename()
        try
            call s:askForConfirmationWhenNewNameAlreadyExists(a:newName)
        catch /already_exists/
            return v:false
        endtry
    endif

    return v:true
endfunction

function! s:shouldAskUserToValidateRename()
    return g:vim_php_refactoring_auto_validate_rename == 0
endfunction

function! s:askForConfirmationWhenNewNameAlreadyExists(newName)
    if s:newNameAlreadyExists(a:newName)
        if s:input.askConfirmation(a:newName . '() seems to already exist in the current class. Rename anyway ?')
            return
        endif

        throw 'already_exists'
    endif
endfunction

function! s:newNameAlreadyExists(newName)
    let l:methodPattern = s:makeMethodPattern(a:newName)

    return s:searchInCurrentClass(l:methodPattern) != s:SEARCH_NO_MATCH
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

function! s:renameMethodName(oldName, newName)
    let l:methodPattern = s:makeMethodPattern(a:oldName)

    call s:replaceInCurrentClass(l:methodPattern, a:newName)
endfunction

function! s:makeMethodPattern(methodName)
    return s:php_regex_before_function.a:methodName.s:regex_after_word_boundary
endfunction

function! s:replaceInCurrentClass(search, replace)
    let l:backupPosition = getcurpos()

    let [l:startLine, l:stopLine] = s:findCurrentClassLineRange()

    exec l:startLine . ',' . l:stopLine . ':s/' . a:search . '/'. a:replace .'/ge'

    call setpos('.', l:backupPosition)
endfunction
