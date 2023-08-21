call refactoring_toolbox#vim#begin_script()

let s:php_regex_func_line = refactoring_toolbox#regex#func_line
let s:regex_after_word_boundary = refactoring_toolbox#regex#after_word_boudary
let s:regex_case_sensitive = refactoring_toolbox#regex#case_sensitive
let s:SEARCH_NOT_FOUND = 0

function! refactoring_toolbox#rename_variable#execute(input)
    let s:input = a:input

    let l:oldName = s:readNameOnCurrentPosition()
    let l:newName = s:askForNewName(l:oldName)

    if s:canRenameVariableTo(l:newName)
        call s:renameVariableName(l:oldName, l:newName)
    endif
endfunction

function! s:readNameOnCurrentPosition()
    return substitute(expand('<cword>'), '^\$*', '', '')
endfunction

function! s:askForNewName(oldName)
    return s:input.askQuestionWithProposedAnswer('Rename '.a:oldName.' to:', a:oldName)
endfunction

function s:canRenameVariableTo(newName)
    if s:shouldAskUserToValidateRename(a:newName)
        return s:userConfirmRename(a:newName)
    endif

    return v:true
endfunction

function! s:shouldAskUserToValidateRename(newName)
    if s:autoValidateRenameIsEnabled()
        return v:false
    endif

    return s:newNameAlreadyExists(a:newName)
endfunction

function s:autoValidateRenameIsEnabled()
    return g:refactoring_toolbox_auto_validate_rename == 1
endfunction

function! s:newNameAlreadyExists(newName)
    let l:variablePattern = s:makeVariablePattern(a:newName)

    return s:searchInCurrentFunction(l:variablePattern) != s:SEARCH_NOT_FOUND
endfunction

function! s:makeVariablePattern(variableName)
    return s:regex_case_sensitive.'$'.a:variableName.s:regex_after_word_boundary
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
    return search('\%>'.a:startLine.'l\%<'.a:endLine.'l'.a:pattern, 'n')
endfunction

function s:userConfirmRename(newName)
    let l:question = '$'.a:newName.' seems to already exist in the current function scope. Rename anyway ?'

    return s:input.askConfirmation(l:question)
endfunction

function! s:renameVariableName(oldName, newName)
    let l:variablePattern = s:makeVariablePattern(a:oldName)

    call s:replaceInCurrentFunction(l:variablePattern, '$'.a:newName)
endfunction

function! s:replaceInCurrentFunction(search, replace)
    let l:backupPosition = getcurpos()

    let [l:startLine, l:stopLine] = s:findCurrentFunctionLineRange()

    exec l:startLine . ',' . l:stopLine . ':s/' . a:search . '/'. a:replace .'/ge'

    call setpos('.', l:backupPosition)
endfunction

call refactoring_toolbox#vim#end_script()
