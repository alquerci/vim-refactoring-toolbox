call refactoring_toolbox#adaptor#vim#begin_script()

let s:NULL = 'NONE'
let s:NO_MATCH = -1
let s:EXPR_NOT_FOUND = -1

function refactoring_toolbox#extract_method#method_extractor#extractSelectedBlock(
    \ input,
    \ language,
    \ texteditor,
    \ output
\ )
    let s:input = a:input
    let s:language = a:language
    let s:texteditor = a:texteditor
    let s:output = a:output

    try
        call s:validateMode()

        let l:methodDefinition = #{
            \ name: s:NULL,
            \ visibility: s:NULL,
            \ arguments: [],
            \ returnVariables: [],
            \ isStatic: s:NULL,
            \ isInlineCall: s:NULL
        \ }

        let l:methodDefinition.name = s:askForMethodName()
        let l:methodDefinition.visibility = s:getVisibility(g:refactoring_toolbox_default_method_visibility)

        let l:methodCallInsertPosition = s:determinePositionToInsertMethodCall()
        let l:codeToExtract = s:getSelectedText()

        call s:texteditor.deleteSelectedText()

        let l:methodDefinition.isStatic = s:language.positionIsInStaticMethod(l:methodCallInsertPosition)
        let l:methodDefinition.isInlineCall = s:isInlineCode()

        let l:methodDefinition.arguments = s:extractArguments(l:codeToExtract, l:methodCallInsertPosition)
        let l:methodDefinition.returnVariables = s:extractReturnVariables(l:codeToExtract, l:methodCallInsertPosition)

        call s:insertMethodCall(l:codeToExtract, l:methodDefinition, l:methodCallInsertPosition)
        call s:addMethod(l:codeToExtract, l:methodDefinition, l:methodCallInsertPosition)
    catch /user_cancel/
        call s:output.echoWarning('You cancelled extract method.')

        return
    catch /unexpected_mode/
        call s:output.echoError('Extract method doesn''t works in Visual Block mode. Use Visual line or Visual mode.')

        return
    endtry
endfunction

function s:validateMode()
    if s:texteditor.isInVisualBlockMode()
        throw 'unexpected_mode'
    endif
endfunction

function s:askForMethodName()
    return s:input.askQuestion('Name of new method?')
endfunction

function s:getVisibility(default)
    if g:refactoring_toolbox_auto_validate_visibility == 0
        return s:askForMethodVisibility(a:default)
    endif

    return a:default
endfunction

function s:getSelectedText()
    let l:startPosition = s:texteditor.getStartPositionOfSelection()
    let l:endPosition = s:texteditor.getEndPositionOfSelection()

    let l:selectionLines = s:texteditor.getLinesBetweenCursorPositions(l:startPosition, l:endPosition)

    return join(l:selectionLines, "\n")
endfunction

function s:determinePositionToInsertMethodCall()
    return s:texteditor.getStartPositionOfSelection()
endfunction

function s:extractArguments(codeToExtract, position)
    let l:methodCodeBefore = s:collectMethodCodeBeforePosition(a:position)

    return s:extractVariablesPresentInBothCode(a:codeToExtract, l:methodCodeBefore)
endfunction

function s:extractReturnVariables(codeToExtract, position)
    if s:language.codeHasReturn(a:codeToExtract)
        return []
    endif

    let l:methodCodeAfter = s:collectMethodCodeAfterPosition(a:position)

    return s:extractMutatedVariablesUsedAfter(a:codeToExtract, l:methodCodeAfter)
endfunction

function s:extractMutatedVariablesUsedAfter(code, codeAfter)
    let l:variables = []


    let l:mutatedVariables = s:extractMutatedLocalVariables(a:code)

    for l:variable in l:mutatedVariables
        if s:language.variableExistsOnCode(l:variable, a:codeAfter)
            call add(l:variables, l:variable)
        endif
    endfor

    return l:variables
endfunction

function s:insertMethodCall(codeToExtract, definition, position)
    call s:texteditor.moveToPosition(a:position)

    let l:statement = s:makeMethodCallStatement(a:codeToExtract, a:definition)

    call s:texteditor.writeText(l:statement)

    call s:texteditor.backToPreviousPosition()
endfunction

function s:makeMethodCallStatement(codeToExtract, definition)
    let l:indent = s:getBaseIndentOfText(a:codeToExtract)

    let l:statement = s:language.makeMethodCallStatement(a:codeToExtract, a:definition)

    return s:applyIndentOnText(l:indent, l:statement)
endfunction

function s:addMethod(codeToExtract, definition, position)
    call s:texteditor.moveToPosition(a:position)

    call s:language.moveEndOfFunction()

    let l:methodBody = s:prepareMethodBody(a:codeToExtract, a:definition)
    call s:insertMethod(a:definition, l:methodBody)

    call s:texteditor.backToPreviousPosition()
endfunction

function s:prepareMethodBody(codeToExtract, definition)
    let l:returnVariables = a:definition.returnVariables
    let l:indent = s:getMethodBodyIndentation()

    if a:definition.isInlineCall
        let l:methodBody = s:language.makeInlineCodeToMethodBody(a:codeToExtract)

        return s:applyIndentOnText(l:indent, l:methodBody)
    else
        let l:methodBody = s:language.prepareMethodBody(a:definition, a:codeToExtract)
        let l:returnStatement = s:prepareReturnStatement(a:definition)

        return s:joinTwoCodeBlock(
            \ s:applyIndentOnText(l:indent, l:methodBody),
            \ s:applyIndentOnText(l:indent, l:returnStatement)
        \ )
    endif
endfunction

function s:prepareReturnStatement(definition)
    if 0 < len(a:definition.returnVariables)
        return s:language.makeReturnStatement(a:definition)
    endif
endfunction

function s:applyIndentOnText(indent, text)
    if '' == a:text
        return ''
    endif

    let l:currentIndent = s:getBaseIndentOfText(a:text)

    let l:text = substitute(a:text, '^'.l:currentIndent, a:indent, 'g')
    let l:text = substitute(l:text, '\n'.l:currentIndent, '\n'.a:indent, 'g')

    return substitute(l:text, '\n$', '', 'g')
endfunction

function s:joinTwoCodeBlock(top, bottom)
    if '' == a:bottom
        return a:top
    endif

    if '' == a:top
        return a:bottom
    endif

    return a:top."\<Enter>\<Enter>".a:bottom
endfunction

function s:isInlineCode()
    return s:texteditor.isInVisualMode()
endfunction

function s:getBaseIndentOfText(text)
    return substitute(a:text, '\S.*', '', '')
endfunction

function s:askForMethodVisibility(default)
    return s:input.askQuestion('Visibility?', a:default)
endfunction

function s:collectMethodCodeAfterPosition(position)
    let l:bottomLine = s:language.getBottomLineOfMethodWithPosition(a:position)

    return join(s:texteditor.getLinesBetweenPositionAndLine(a:position, l:bottomLine))
endfunction

function s:collectMethodCodeBeforePosition(position)
    let l:topLine = s:language.getTopLineOfMethodWithPosition(a:position)

    return join(s:texteditor.getLinesBetweenCursorPositions(l:topLine, a:position))
endfunction

function s:extractVariablesPresentInBothCode(first, second)
    let l:variables = []

    for l:variable in s:extractAllLocalVariables(a:first)
        if s:language.variableExistsOnCode(l:variable, a:second)
            call add(l:variables, l:variable)
        endif
    endfor

    return l:variables
endfunction

function s:extractAllLocalVariables(haystack)
    return s:extractStringListThatMatchPatternWithCondition(
        \ a:haystack,
        \ s:language.getLocalVariablePattern()
    \ )
endfunction

function s:extractMutatedLocalVariables(haystack)
    return s:extractStringListThatMatchPatternWithCondition(
        \ a:haystack,
        \ s:language.getMutatedLocalVariablePattern()
    \ )
endfunction

function s:extractStringListThatMatchPatternWithCondition(haystack, conditionPattern)
    let l:strings = []
    let l:atOccurence = 0
    let l:foundString = s:findTextMatchingPatternOnTextAtOccurence(a:conditionPattern, a:haystack, l:atOccurence)

    while '' != l:foundString
        call s:listAddOnce(l:strings, l:foundString)

        let l:atOccurence += 1
        let l:foundString = s:findTextMatchingPatternOnTextAtOccurence(a:conditionPattern, a:haystack, l:atOccurence)
    endwhile

    return l:strings
endfunction

function s:findTextMatchingPatternOnTextAtOccurence(pattern, text, occurence)
    return matchstr(a:text, a:pattern, 0, a:occurence)
endfunction

function s:listAddOnce(list, value)
    if s:EXPR_NOT_FOUND == index(a:list, a:value)
        call add(a:list, a:value)
    endif
endfunction

function s:insertMethod(definition, body)
    let l:indent = s:getMethodIndentation()

    call s:texteditor.writeLine('')
    call s:texteditor.writeLine(l:indent.s:language.makeMethodFirstLine(a:definition))
    call s:texteditor.writeLine(l:indent.'{')
    call s:texteditor.writeLine('')
    call s:texteditor.writeText(a:body)
    call s:texteditor.writeLine(l:indent.'}')
endfunction

function s:getMethodIndentation()
    return s:texteditor.getIndentForLevel(s:language.getMethodIndentationLevel())
endfunction

function s:getMethodBodyIndentation()
    return s:texteditor.getIndentForLevel(s:language.getMethodIndentationLevel() + 1)
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
