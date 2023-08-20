call php_refactoring_toolbox#vim#begin_script()

let s:php_regex_class_line = php_refactoring_toolbox#regex#class_line
let s:regex_after_word_boundary = php_refactoring_toolbox#regex#after_word_boudary
let s:regex_case_sensitive = php_refactoring_toolbox#regex#case_sensitive
let s:regex_property_declaration_or_usage = php_refactoring_toolbox#regex#member_declaration_or_usage
let s:regex_lookbehind_positive = php_refactoring_toolbox#regex#lookbehind_positive
let s:SEARCH_NOT_FOUND = 0

function! php_refactoring_toolbox#rename_property#execute(input)
    let s:input = a:input

    let l:oldName = s:readNameOnCurrentPosition()
    let l:newName = s:askForNewName(l:oldName)

    if s:canRenamePropertyTo(l:newName)
        call s:replacePropertyName(l:oldName, l:newName)
    endif
endfunction

function! s:readNameOnCurrentPosition()
    return substitute(expand('<cword>'), '^\$*', '', '')
endfunction

function! s:askForNewName(oldName)
    return s:input.askQuestionWithProposedAnswer('Rename '.a:oldName.' to:', a:oldName)
endfunction

function s:canRenamePropertyTo(newName)
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
        if s:input.askConfirmation('Property named '.a:newName.' seems to already exist in the current class. Rename anyway ?')
            return
        endif

        throw 'already_exists'
    endif
endfunction

function! s:newNameAlreadyExists(newName)
    let l:propertyPattern = s:makePropertyPattern(a:newName)

    return s:searchInCurrentClass(l:propertyPattern) != s:SEARCH_NOT_FOUND
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

function! s:replacePropertyName(oldName, newName)
    let l:propertyPattern = s:makePropertyPattern(a:oldName)

    call s:replaceInCurrentClass(l:propertyPattern, a:newName)
endfunction

function! s:makePropertyPattern(propertyName)
    let l:is_prefixed_with_property_marker = s:regex_case_sensitive.s:regex_property_declaration_or_usage.s:regex_lookbehind_positive

    return l:is_prefixed_with_property_marker.a:propertyName.s:regex_after_word_boundary
endfunction

function! s:replaceInCurrentClass(search, replace)
    let l:backupPosition = getcurpos()

    let [l:startLine, l:stopLine] = s:findCurrentClassLineRange()

    exec l:startLine . ',' . l:stopLine . ':s/' . a:search . '/'. a:replace .'/ge'

    call setpos('.', l:backupPosition)
endfunction

call php_refactoring_toolbox#vim#end_script()
