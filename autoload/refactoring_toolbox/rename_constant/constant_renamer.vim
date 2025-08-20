call refactoring_toolbox#adapters#vim#begin_script()

let s:SEARCH_NOT_FOUND = 0

function refactoring_toolbox#rename_constant#constant_renamer#execute(input, output, texteditor, language)
    let s:input = a:input
    let s:output = a:output
    let s:texteditor = a:texteditor
    let s:language = a:language

    try
        let l:oldName = s:readNameOnCurrentPosition()
        let l:newName = s:askForNewName(l:oldName)

        let l:newName = s:language.formatConstant(l:newName)

        if s:canRenameConstantTo(l:newName)
            call s:renameConstantNameWithNewName(l:oldName, l:newName)
        endif
    catch /user_cancel/
        call s:output.echoWarning('You cancelled rename constant.')
    endtry
endfunction

function s:readNameOnCurrentPosition()
    let l:word = s:texteditor.getWordOnCursor()

    return s:language.parseConstant(l:word)
endfunction

function s:askForNewName(oldName)
    let l:answer = s:input.askQuestionWithProposedAnswer('Rename '.a:oldName.' to:', a:oldName)

    if '' == l:answer
        throw 'user_cancel'
    endif

    return l:answer
endfunction

function s:canRenameConstantTo(newName)
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
        if s:input.askConfirmation('Constant named '.a:newName.' seems to already exist in the current class. Rename anyway ?')
            return
        endif

        throw 'already_exists'
    endif
endfunction

function s:newNameAlreadyExists(newName)
    let l:constantPattern = s:language.makeConstantPattern(a:newName)

    return s:patternMatchesInCurrentClass(l:constantPattern)
endfunction

function s:patternMatchesInCurrentClass(pattern)
    let [l:startLine, l:stopLine] = s:language.findCurrentClassLineRange()

    return s:texteditor.patternMatchesBetweenLines(a:pattern, l:startLine, l:stopLine)
endfunction

function s:renameConstantNameWithNewName(oldName, newName)
    let l:constantPattern = s:language.makeConstantPattern(a:oldName)

    call s:replaceInCurrentClass(l:constantPattern, a:newName)
endfunction

function s:replaceInCurrentClass(search, replace)
    let [l:startLine, l:stopLine] = s:language.findCurrentClassLineRange()

    call s:texteditor.replacePatternWithTextBetweenLines(a:search, a:replace, l:startLine, l:stopLine)
endfunction

call refactoring_toolbox#adapters#vim#end_script()
