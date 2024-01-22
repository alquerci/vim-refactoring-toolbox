call refactoring_toolbox#adaptor#vim#begin_script()

let s:php_regex_class_line = refactoring_toolbox#adaptor#regex#class_line
let s:php_regex_func_line = refactoring_toolbox#adaptor#regex#func_line
let s:regex_after_word_boundary = refactoring_toolbox#adaptor#regex#after_word_boudary
let s:php_regex_before_function = '\%(\%('.s:php_regex_func_line.'\)\|$this->\|self::\)\@<='
let s:SEARCH_NO_MATCH = 0

function refactoring_toolbox#rename_method#method_renamer#execute(input, output, texteditor)
    let s:input = a:input
    let s:output = a:output
    let s:texteditor = a:texteditor

    try
        let l:oldName = s:readNameOnCurrentPosition()
        let l:newName = s:askForNewName(l:oldName)

        if s:canRenameMethodTo(l:newName)
            call s:renameMethodName(l:oldName, l:newName)
        endif
    catch /user_cancel/
        call s:output.echoWarning('You cancelled rename method.')
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

function s:shouldAskUserToValidateRename()
    return g:refactoring_toolbox_auto_validate_rename == 0
endfunction

function s:askForConfirmationWhenNewNameAlreadyExists(newName)
    if s:newNameAlreadyExists(a:newName)
        if s:input.askConfirmation(a:newName . '() seems to already exist in the current class. Rename anyway ?')
            return
        endif

        throw 'already_exists'
    endif
endfunction

function s:newNameAlreadyExists(newName)
    let l:methodPattern = s:makeMethodPattern(a:newName)

    return s:searchInCurrentClass(l:methodPattern) != s:SEARCH_NO_MATCH
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

function s:renameMethodName(oldName, newName)
    let l:methodPattern = s:makeMethodPattern(a:oldName)

    call s:replaceInCurrentClass(l:methodPattern, a:newName)
endfunction

function s:makeMethodPattern(methodName)
    return s:php_regex_before_function.a:methodName.s:regex_after_word_boundary
endfunction

function s:replaceInCurrentClass(search, replace)
    let [l:startLine, l:stopLine] = s:findCurrentClassLineRange()

    call s:texteditor.replacePatternWithTextBetweenLines(a:search, a:replace, l:startLine, l:stopLine)
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
