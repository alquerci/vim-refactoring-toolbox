call refactoring_toolbox#adapters#vim#begin_script()

let s:php_regex_class_line = refactoring_toolbox#adapters#regex#class_line
let s:regex_after_word_boundary = refactoring_toolbox#adapters#regex#after_word_boundary
let s:regex_case_sensitive = refactoring_toolbox#adapters#regex#case_sensitive
let s:regex_property_declaration_or_usage = refactoring_toolbox#adapters#regex#member_declaration_or_usage
let s:regex_lookbehind_positive = refactoring_toolbox#adapters#regex#lookbehind_positive
let s:SEARCH_NOT_FOUND = 0

function refactoring_toolbox#rename_property#property_renamer#execute(input, output, texteditor)
    let s:input = a:input
    let s:output = a:output
    let s:texteditor = a:texteditor

    try
        let l:oldName = s:readNameOnCurrentPosition()
        let l:newName = s:askForNewName(l:oldName)

        if s:canRenamePropertyTo(l:newName)
            call s:replacePropertyName(l:oldName, l:newName)
        endif
    catch /user_cancel/
        call s:output.echoWarning('You cancelled rename property.')
    endtry
endfunction

function s:readNameOnCurrentPosition()
    return substitute(expand('<cword>'), '^\$*', '', '')
endfunction

function s:askForNewName(oldName)
    let l:answer = s:input.askQuestionWithProposedAnswer('Rename '.a:oldName.' to:', a:oldName)

    if '' == l:answer
        throw 'user_cancel'
    endif

    return l:answer
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

function s:shouldAskUserToValidateRename()
    return g:refactoring_toolbox_auto_validate_rename == 0
endfunction

function s:askForConfirmationWhenNewNameAlreadyExists(newName)
    if s:newNameAlreadyExists(a:newName)
        if s:input.askConfirmation('Property named '.a:newName.' seems to already exist in the current class. Rename anyway ?')
            return
        endif

        throw 'already_exists'
    endif
endfunction

function s:newNameAlreadyExists(newName)
    let l:propertyPattern = s:makePropertyPattern(a:newName)

    return s:searchInCurrentClass(l:propertyPattern) != s:SEARCH_NOT_FOUND
endfunction

function s:searchInCurrentClass(pattern)
    let [l:startLine, l:stopLine] = s:findCurrentClassLineRange()

    return s:searchInRange(a:pattern, l:startLine, l:stopLine)
endfunction

function s:findCurrentClassLineRange()
    let l:backupPosition = getcurpos()

    call search(s:php_regex_class_line, 'beW')
    call search('{', 'W')
    let l:startLine = line('.')
    call searchpair('{', '', '}', 'W')
    let l:stopLine = line('.')

    call setpos('.', l:backupPosition)

    return [l:startLine, l:stopLine]
endfunction

function s:searchInRange(pattern, startLine, endLine)
    return search('\%>' . a:startLine . 'l\%<' . a:endLine . 'l' . a:pattern, 'n')
endfunction

function s:replacePropertyName(oldName, newName)
    let l:propertyPattern = s:makePropertyPattern(a:oldName)

    call s:replaceInCurrentClass(l:propertyPattern, a:newName)
endfunction

function s:makePropertyPattern(propertyName)
    let l:is_prefixed_with_property_marker = s:regex_case_sensitive.s:regex_property_declaration_or_usage.s:regex_lookbehind_positive

    return l:is_prefixed_with_property_marker.a:propertyName.s:regex_after_word_boundary
endfunction

function s:replaceInCurrentClass(search, replace)
    let [l:startLine, l:stopLine] = s:findCurrentClassLineRange()

    call s:texteditor.replacePatternWithTextBetweenLines(a:search, a:replace, l:startLine, l:stopLine)
endfunction

call refactoring_toolbox#adapters#vim#end_script()
