call refactoring_toolbox#adapters#vim#begin_script()

let s:SEARCH_NOT_FOUND = 0

function refactoring_toolbox#rename_variable#variable_renamer#execute(language, input, output, texteditor)
    let s:language = a:language
    let s:input = a:input
    let s:output = a:output
    let s:texteditor = a:texteditor

    let l:backupPosition = getcurpos()

    try
        let l:oldName = s:readNameOnCurrentPosition()
        let l:newName = s:askForNewName(l:oldName)

        call s:moveToVariableDefinition(l:oldName)

        if s:canRenameVariableTo(l:newName)
            call s:renameVariableName(l:oldName, l:newName)
        endif
    catch /user_cancel/
        call s:output.echoWarning('You cancelled rename variable.')
    endtry

    call setpos('.', l:backupPosition)
endfunction

function s:readNameOnCurrentPosition()
    return s:language.parseVariable(expand('<cword>'))
endfunction

function s:askForNewName(oldName)
    let l:answer = s:input.askQuestionWithProposedAnswer('Rename '.a:oldName.' to:', a:oldName)

    if '' == l:answer
        throw 'user_cancel'
    endif

    return l:answer
endfunction

function s:canRenameVariableTo(newName)
    if s:shouldAskUserToValidateRename(a:newName)
        return s:userConfirmRename(a:newName)
    endif

    return v:true
endfunction

function s:shouldAskUserToValidateRename(newName)
    if s:autoValidateRenameIsEnabled()
        return v:false
    endif

    return s:newNameAlreadyExists(a:newName)
endfunction

function s:autoValidateRenameIsEnabled()
    return g:refactoring_toolbox_auto_validate_rename == 1
endfunction

function s:newNameAlreadyExists(newName)
    let l:backupPosition = getcurpos()

    let l:variablePattern = s:language.makeVariablePattern(a:newName)

    let l:exists =  s:currentFunctionContainsPattern(l:variablePattern)

    call setpos('.', l:backupPosition)

    return l:exists
endfunction

function s:moveToVariableDefinition(name)
    if !s:containsPatternInRange(s:language.makeVariableDefinitionPattern(a:name), line('.'), line('.'))
        let [l:startLine, l:endLine] = s:language.findCurrentFunctionDefinitionLineRange()

        if s:containsPatternInRange(s:language.makeVariablePattern(a:name), l:startLine, l:endLine)
            return
        else
            let [l:startLine, l:endLine] = s:language.findParentScopeLineRange()

            call s:moveToPatternInRange(s:language.makeVariablePattern(a:name), l:startLine, l:endLine)
        endif
    endif
endfunction

function s:moveToPatternInRange(pattern, startLine, endLine)
    call cursor(a:startLine, 1)
    call search('\%>'.(a:startLine - 1).'l\%<'.(a:endLine + 1).'l'.a:pattern, 'cW')
endfunction

function s:currentFunctionContainsPattern(pattern)
    let [l:startLine, l:endLine] = s:language.findCurrentFunctionLineRange()

    return s:containsPatternInRange(a:pattern, l:startLine, l:endLine)
endfunction

function s:containsPatternInRange(pattern, startLine, endLine)
    return search('\%>'.(a:startLine - 1).'l\%<'.(a:endLine + 1).'l'.a:pattern, 'n') != s:SEARCH_NOT_FOUND
endfunction

function s:userConfirmRename(newName)
    let l:question = s:language.formatVariable(a:newName).' seems to already exist in the current function scope. Rename anyway ?'

    return s:input.askConfirmation(l:question)
endfunction

function s:renameVariableName(oldName, newName)
    let l:backupPosition = getcurpos()

    let l:variablePattern = s:language.makeVariablePattern(a:oldName)

    call s:replaceInCurrentFunction(l:variablePattern, s:language.formatVariable(a:newName))

    call setpos('.', l:backupPosition)
endfunction

function s:replaceInCurrentFunction(search, replace)
    let [l:startLine, l:endLine] = s:language.findCurrentFunctionLineRange()


    call s:texteditor.replacePatternWithTextBetweenLines(a:search, a:replace, l:startLine, l:endLine)
endfunction

call refactoring_toolbox#adapters#vim#end_script()
