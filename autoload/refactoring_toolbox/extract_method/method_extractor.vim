call refactoring_toolbox#adaptor#vim#begin_script()

let s:NULL = 'NONE'
let s:EXPR_NOT_FOUND = -1
let s:NO_MATCH = -1
let s:EOL = "\n"

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
            \ isInlineCall: s:NULL,
            \ indentationLevel: s:NULL,
            \ callPosition: s:NULL,
        \ }

        let l:methodDefinition.name = s:askForMethodName()
        let l:methodDefinition.visibility = s:getVisibility(g:refactoring_toolbox_default_method_visibility)

        let l:methodCallInsertPosition = s:determinePositionToInsertMethodCall()
        let l:methodDefinition.callPosition = l:methodCallInsertPosition
        let l:codeToExtract = s:getSelectedText()

        call s:texteditor.deleteSelectedText()

        let l:methodDefinition.isStatic = s:language.positionIsInStaticMethod(l:methodCallInsertPosition)
        let l:methodDefinition.isInlineCall = s:isInlineCode()
        let l:methodDefinition.indentationLevel = s:determineIndentationLevelOfMethodBodyPosition(l:methodCallInsertPosition)

        let l:methodDefinition.arguments = s:extractArguments(l:codeToExtract, l:methodCallInsertPosition)
        let l:methodDefinition.returnVariables = s:extractReturnVariables(l:codeToExtract, l:methodCallInsertPosition)

        call s:insertMethodCall(l:methodDefinition, l:codeToExtract, l:methodCallInsertPosition)
        call s:addMethod(l:methodDefinition, l:codeToExtract, l:methodCallInsertPosition)
    catch /user_cancel/
        call s:output.echoWarning('You cancelled extract method.')
    catch /unexpected_mode/
        call s:output.echoError('Extract method doesn''t works in Visual Block mode. Use Visual line or Visual mode.')
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

    return join(l:selectionLines, s:EOL)
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

function s:insertMethodCall(definition, codeToExtract, position)
    call s:texteditor.moveToPosition(a:position)

    let l:statement = s:makeMethodCallStatement(a:definition, a:codeToExtract)

    call s:texteditor.writeText(l:statement)

    call s:texteditor.backToPreviousPosition()
endfunction

function s:makeMethodCallStatement(definition, codeToExtract)
    let l:indent = s:getStartIndentOfText(a:codeToExtract)

    let l:statement = s:language.makeMethodCallStatement(a:definition, a:codeToExtract)

    return s:applyIndentOnText(l:indent, l:statement)
endfunction

function s:getStartIndentOfText(text)
    return substitute(a:text, '\S.*', '', '')
endfunction

function s:addMethod(definition, codeToExtract, position)
    call s:texteditor.moveToPosition(a:position)

    call s:language.moveEndOfFunction()

    let l:methodBody = s:prepareMethodBody(a:definition, a:codeToExtract)
    call s:insertMethod(a:definition, l:methodBody)

    call s:texteditor.backToPreviousPosition()
endfunction

function s:prepareMethodBody(definition, codeToExtract)
    let l:indent = s:getMethodBodyIndentation(a:definition)

    if a:definition.isInlineCall
        let l:methodBody = s:language.makeInlineCodeToMethodBody(a:codeToExtract)

        return s:applyIndentOnTextForInlineCall(l:indent, l:methodBody)
    else
        let l:methodBody = s:language.prepareMethodBody(a:definition, a:codeToExtract)
        let l:returnStatement = s:language.makeReturnStatement(a:definition)

        return s:joinTwoCodeBlock(
            \ s:applyIndentOnText(l:indent, l:methodBody),
            \ s:applyIndentOnText(l:indent, l:returnStatement)
        \ )
    endif
endfunction

function s:applyIndentOnText(indent, text)
    if '' == a:text
        return ''
    endif

    let l:lines = split(a:text, s:EOL)

    let l:lines = s:applyIndentOnLines(a:indent, l:lines)

    return join(l:lines, s:EOL)
endfunction

function s:applyIndentOnLines(indent, lines)
    let l:withIndentLines = []

    let l:fromIndent = s:getMinimumIndentOfLines(a:lines)

    for l:line in a:lines
        let l:line = substitute(l:line, '^'.l:fromIndent, a:indent, '')

        call add(l:withIndentLines, l:line)
    endfor

    return l:withIndentLines
endfunction

function s:getMinimumIndentOfLines(lines)
    let l:minIndent = s:getStartIndentOfText(a:lines[0])

    for l:line in a:lines
        if '' == l:line
            continue
        endif

        let l:lineIndent = s:getStartIndentOfText(l:line)

        if len(l:minIndent) > len(l:lineIndent)
            let l:minIndent = l:lineIndent
        endif
    endfor

    return l:minIndent
endfunction

function s:applyIndentOnTextForInlineCall(indent, text)
    if '' == a:text
        return ''
    endif

    let l:lines = split(a:text, s:EOL)

    let l:firstLine = a:indent.l:lines[0]
    let l:nextLines = s:applyIndentOnTextExceptFirstLine(a:indent, l:lines)

    let l:indentedLines = extend([l:firstLine], l:nextLines)

    return join(l:indentedLines, s:EOL)
endfunction

function s:applyIndentOnTextExceptFirstLine(indent, lines)
    if 1 < len(a:lines)
        return s:applyIndentOnLines(a:indent, a:lines[1:])
    else
        return []
    endif
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

function s:determineIndentationLevelOfMethodBodyPosition(position)
    let l:topLine = s:language.getTopLineOfMethodWithPosition(a:position)

    return s:texteditor.getIndentationLevelOfLine(l:topLine)
endfunction

function s:askForMethodVisibility(default)
    return s:input.askQuestion('Visibility?', a:default)
endfunction

function s:collectMethodCodeAfterPosition(position)
    let l:bottomLine = s:language.getBottomLineOfMethodWithPosition(a:position)

    return join(s:texteditor.getLinesBetweenPositionAndLine(a:position, l:bottomLine))
endfunction

function s:collectMethodCodeBeforePosition(position)
    let l:topPosition = s:language.getTopPositionOfMethodWithPosition(a:position)

    return join(s:texteditor.getLinesBetweenCursorPositions(l:topPosition, a:position))
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
    let l:atOccurence = 1
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
    call s:texteditor.writeLine('')

    let l:indent = s:getMethodIndentation(a:definition)

    let l:headerLines = s:language.makeMethodHeaderLines(a:definition)
    call s:writeLinesWithIndent(l:headerLines, l:indent)

    call s:texteditor.writeLine('')
    call s:texteditor.writeText(a:body)

    let l:footerLines = s:language.makeMethodFooterLines(a:definition)
    call s:writeLinesWithIndent(l:footerLines, l:indent)
endfunction

function s:getMethodIndentation(definition)
    return s:texteditor.getIndentForLevel(a:definition.indentationLevel)
endfunction

function s:getMethodBodyIndentation(definition)
    return s:texteditor.getIndentForLevel(a:definition.indentationLevel + 1)
endfunction

function s:writeLinesWithIndent(lines, indent)
    for l:line in a:lines
        if ('' != l:line)
            let l:line = a:indent.l:line
        endif

        call s:texteditor.writeLine(l:line)
    endfor
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
