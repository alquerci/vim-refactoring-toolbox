call refactoring_toolbox#adapters#vim#begin_script()

let s:regex_after_word_boundary = refactoring_toolbox#adapters#regex#after_word_boudary
let s:regex_case_sensitive = refactoring_toolbox#adapters#regex#case_sensitive
let s:SEARCH_NOT_FOUND = 0

function refactoring_toolbox#rename_variable#variable_renamer#execute(language, input, output, texteditor)
    let s:language = a:language
    let s:input = a:input
    let s:output = a:output
    let s:texteditor = a:texteditor

    try
        let l:oldName = s:readNameOnCurrentPosition()
        let l:newName = s:askForNewName(l:oldName)

        if s:canRenameVariableTo(l:newName)
            call s:renameVariableName(l:oldName, l:newName)
        endif
    catch /user_cancel/
        call s:output.echoWarning('You cancelled rename variable.')
    endtry
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
    let l:variablePattern = s:makeVariablePattern(a:newName)

    return s:searchInCurrentFunction(l:variablePattern) != s:SEARCH_NOT_FOUND
endfunction

function s:makeVariablePattern(variableName)
    return s:regex_case_sensitive.s:language.formatVariable(a:variableName).s:regex_after_word_boundary
endfunction

function s:searchInCurrentFunction(pattern)
    let [l:startLine, l:stopLine] = s:language.findCurrentFunctionLineRange()

    return s:searchInRange(a:pattern, l:startLine, l:stopLine)
endfunction

function s:searchInRange(pattern, startLine, endLine)
    return search('\%>'.a:startLine.'l\%<'.a:endLine.'l'.a:pattern, 'n')
endfunction

function s:userConfirmRename(newName)
    let l:question = s:language.formatVariable(a:newName).' seems to already exist in the current function scope. Rename anyway ?'

    return s:input.askConfirmation(l:question)
endfunction

function s:renameVariableName(oldName, newName)
    let l:variablePattern = s:makeVariablePattern(a:oldName)

    call s:replaceInCurrentFunction(l:variablePattern, s:language.formatVariable(a:newName))
endfunction

function s:replaceInCurrentFunction(search, replace)
    let [l:startLine, l:stopLine] = s:language.findCurrentFunctionLineRange()

    call s:texteditor.replacePatternWithTextBetweenLines(a:search, a:replace, l:startLine, l:stopLine)
endfunction

call refactoring_toolbox#adapters#vim#end_script()
