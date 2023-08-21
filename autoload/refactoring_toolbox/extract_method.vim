call refactoring_toolbox#vim#begin_script()

let s:php_regex_func_line = refactoring_toolbox#regex#func_line
let s:php_regex_static_func = refactoring_toolbox#regex#static_func
let s:php_regex_member_line = refactoring_toolbox#regex#member_line
let s:php_regex_const_line = refactoring_toolbox#regex#const_line
let s:php_regex_local_var = refactoring_toolbox#regex#local_var
let s:php_regex_local_var_mutate = refactoring_toolbox#regex#local_var_mutate
let s:NULL = 'NONE'
let s:NO_MATCH = -1
let s:EXPR_NOT_FOUND = -1

function! refactoring_toolbox#extract_method#execute(input)
    let s:input = a:input

    try
        call s:validateMode()

        let l:methodDefinition = #{name: s:NULL, visibility: s:NULL, arguments: [], returnVariables: [], isStatic: s:NULL}

        let l:methodDefinition.name = s:askForMethodName()
        let l:methodDefinition.visibility = s:getVisibility(g:refactoring_toolbox_default_method_visibility)

        let l:codeToExtract = s:cutCodeToExtractAndMoveToInsertPosition()
        let l:methodDefinition.isStatic = s:insertPositionIsInStaticMethod()

        let l:methodDefinition.arguments = s:extractArguments(l:codeToExtract)
        let l:methodDefinition.returnVariables = s:extractReturnVariables(l:codeToExtract)

        call s:insertMethodCall(l:codeToExtract, l:methodDefinition)
        call s:addMethod(l:codeToExtract, l:methodDefinition)
    catch /user_cancel/
        call s:echoWarning('You cancelled extract method.')

        return
    catch /unexpected_mode/
        call s:echoError('Extract method doesn''t works in Visual Block mode. Use Visual line or Visual mode.')

        return
    endtry
endfunction

function! s:validateMode()
    if s:isInVisualBlockMode()
        throw 'unexpected_mode'
    endif
endfunction

function! s:askForMethodName()
    return s:input.askQuestion('Name of new method?')
endfunction

function! s:getVisibility(default)
    if g:refactoring_toolbox_auto_validate_visibility == 0
        return s:askForMethodVisibility(a:default)
    endif

    return a:default
endfunction

function! s:cutCodeToExtractAndMoveToInsertPosition()
    normal! gv"xs

    return @x
endfunction

function s:insertPositionIsInStaticMethod()
    let l:definitionLine = search(s:php_regex_func_line, 'bnW')

    return s:definitionAtLineIsStatic(l:definitionLine)
endfunction

function s:definitionAtLineIsStatic(line)
    let l:content = getline(a:line)

    return match(l:content, s:php_regex_static_func) != s:NO_MATCH
endfunction

function! s:extractArguments(codeToExtract)
    let l:methodCodeBefore = s:collectMethodCodeBeforeCurrentLine()

    return s:extractVariablesPresentInBothCode(a:codeToExtract, l:methodCodeBefore)
endfunction

function! s:extractReturnVariables(codeToExtract)
    if s:codeHasReturn(a:codeToExtract)
        return []
    endif

    let l:methodCodeAfter = s:collectMethodCodeAfterCurrentLine()

    return s:extractMutatedVariablesUsedAfter(a:codeToExtract, l:methodCodeAfter)
endfunction

function! s:insertMethodCall(codeToExtract, definition)
    let l:backupPosition = getcurpos()

    let l:statement = s:makeMethodCallStatement(a:codeToExtract, a:definition)

    call s:writeText(l:statement)

    call setpos('.', l:backupPosition)
endfunction

function! s:makeMethodCallStatement(codeToExtract, definition)
    let l:indent = s:getBaseIndentOfText(a:codeToExtract)
    let l:methodCall = s:makeMethodCall(a:codeToExtract, a:definition)

    if s:codeHasReturn(a:codeToExtract)
        return l:indent.'return '.l:methodCall
    else
        let l:assigment = s:makeAssigment(a:definition.returnVariables)

        return l:indent.l:assigment.l:methodCall
    endif
endfunction

function! s:makeMethodCall(codeToExtract, definition)
    let l:endExpression = s:isInlineCode(a:codeToExtract) ? '' : ';'
    let l:arguments = join(a:definition.arguments, ', ')
    let l:context = s:prepareMethodCallContext(a:definition)

    return printf('%s%s(%s)%s', l:context, a:definition.name, l:arguments, l:endExpression)
endfunction

function s:prepareMethodCallContext(definition)
    if a:definition.isStatic
        return 'self::'
    endif

    return '$this->'
endfunction

function! s:makeAssigment(returnVariables)
    if len(a:returnVariables) == 0
        return ''
    elseif len(a:returnVariables) == 1
        return a:returnVariables[0].' = '
    else
        return printf('list(%s)', join(a:returnVariables, ', ')).' = '
    endif
endfunction

function! s:codeHasReturn(code)
    let l:returnKeywordPattern = '^\_s*return\_s'
    let l:lines = split(a:code, "\n")

    return match(l:lines, l:returnKeywordPattern) != s:NO_MATCH
endfunction

function! s:addMethod(codeToExtract, definition)
    let l:backupPosition = getcurpos()

    let l:methodBody = s:prepareMethodBody(a:codeToExtract, a:definition.returnVariables)
    let l:methodModifiers = s:prepareMethodModifiers(a:definition)

    call s:moveEndOfFunction()

    call s:insertMethod(l:methodModifiers, a:definition.name, a:definition.arguments, l:methodBody)

    call setpos('.', l:backupPosition)
endfunction

function! s:prepareMethodBody(codeToExtract, returnVariables)
    let l:returnIndent = s:computeReturnIntent()
    let l:currentIndent = s:getBaseIndentOfText(a:codeToExtract)

    let l:methodBody = substitute(a:codeToExtract, '^'.l:currentIndent, l:returnIndent, 'g')
    let l:methodBody =  substitute(l:methodBody, '\n'.l:currentIndent, '\n'.l:returnIndent, 'g')
    let l:methodBody =  substitute(l:methodBody, '\n$', '', 'g')

    if s:isInlineCode(a:codeToExtract)
        let l:methodBody = ''
    elseif len(a:returnVariables) > 0
        let l:methodBody = l:methodBody."\<Enter>\<Enter>"
    endif

    let l:return = s:prepareReturnStatement(a:codeToExtract, a:returnVariables, l:returnIndent)

    return l:methodBody.l:return
endfunction

function! s:computeReturnIntent()
    let l:baseIndent = s:detectIntentation()

    return l:baseIndent.l:baseIndent
endfunction

function! s:prepareReturnStatement(codeToExtract, returnVariables, returnIndent)
    if s:isInlineCode(a:codeToExtract)
        return a:returnIndent.'return '.a:codeToExtract.';'
    elseif len(a:returnVariables) == 0
        return ''
    elseif len(a:returnVariables) == 1
        return a:returnIndent.'return ' . a:returnVariables[0] . ';'
    else
        return a:returnIndent.'return array(' . join(a:returnVariables, ', ') . ');'
    endif
endfunction

function s:prepareMethodModifiers(definition)
    if a:definition.isStatic
        return a:definition.visibility.' static'
    endif

    return a:definition.visibility
endfunction

function! s:isInlineCode(codeToExtract)
    return !s:isTextEndsWithNewLine(a:codeToExtract)
endfunction

function! s:isTextEndsWithNewLine(text)
    return "\<NL>" == a:text[-1:]
endfunction

function! s:getBaseIndentOfText(text)
    return substitute(a:text, '\S.*', '', '')
endfunction

function! s:askForMethodVisibility(default)
    return s:input.askQuestion('Visibility?', a:default)
endfunction

function! s:collectMethodCodeAfterCurrentLine()
    let l:topLine = s:getCurrentLine()
    let l:bottomLine = s:getBottomLineOfCurrentMethod()

    return s:joinLinesBetween(l:topLine, l:bottomLine)
endfunction

function! s:getBottomLineOfCurrentMethod()
    let l:backupPosition = getcurpos()

    call s:moveEndOfFunction()
    let l:bottomLine = s:getCurrentLine()

    call setpos('.', l:backupPosition)

    return l:bottomLine
endfunction

function! s:collectMethodCodeBeforeCurrentLine()
    let l:topLine = s:getTopLineOfCurrentMethod()
    let l:bottomLine = s:getCurrentLine() - 1

    return s:joinLinesBetween(l:topLine, l:bottomLine)
endfunction

function! s:getTopLineOfCurrentMethod()
    let l:backupPosition = getcurpos()

    call s:moveToCurrentFunctionDefinition()
    let l:topLine = s:getCurrentLine()

    call setpos('.', l:backupPosition)

    return l:topLine
endfunction

function! s:extractMutatedVariablesUsedAfter(code, codeAfter)
    let l:variables = []

    for l:var in s:extractMutatedLocalVariables(a:code)
        if s:variableExistsOnCode(l:var, a:codeAfter)
            call add(l:variables, l:var)
        endif
    endfor

    return l:variables
endfunction

function! s:extractVariablesPresentInBothCode(first, second)
    let l:variables = []

    for l:var in s:extractAllLocalVariables(a:first)
        if s:variableExistsOnCode(l:var, a:second)
            call add(l:variables, l:var)
        endif
    endfor

    return l:variables
endfunction

function! s:variableExistsOnCode(variable, code)
    return match(a:code, a:variable . '\>') != s:NO_MATCH
endfunction

function! s:extractAllLocalVariables(haystack)
    return s:extractStringListThatMatchPatternWithCondition(a:haystack, s:php_regex_local_var, s:php_regex_local_var)
endfunction

function! s:extractMutatedLocalVariables(haystack)
    return s:extractStringListThatMatchPatternWithCondition(a:haystack, s:php_regex_local_var, s:php_regex_local_var_mutate)
endfunction

function! s:extractStringListThatMatchPatternWithCondition(haystack, stringPattern, conditionPattern)
    let l:strings = []
    let l:matchPos = match(a:haystack, a:conditionPattern, 0)

    while l:matchPos != s:NO_MATCH
        let l:str = matchstr(a:haystack, a:stringPattern, l:matchPos)

        if s:EXPR_NOT_FOUND == index(l:strings, l:str)
            call add(l:strings, l:str)
        endif

        let l:matchPos = match(a:haystack, a:conditionPattern, l:matchPos + strlen(l:str))
    endwhile

    return l:strings
endfunction

function! s:joinLinesBetween(topLine, bottomLine)
    return join(getline(a:topLine, a:bottomLine))
endfunction

function! s:moveEndOfFunction()
    call s:moveToCurrentFunctionDefinition()

    call s:moveToClosingBracket()
endfunction

function! s:moveToCurrentFunctionDefinition()
    call search(s:php_regex_func_line, 'bW')
endfunction

function! s:moveToClosingBracket()
    call search('{', 'W')
    call searchpair('{', '', '}', 'W')
endfunction

function! s:insertMethod(modifiers, methodName, params, impl)
    let l:indent = s:detectIntentation()

    call s:writeLine('')
    call s:writeLine(l:indent . a:modifiers . ' function ' . a:methodName . '(' . join(a:params, ', ') . ')')
    call s:writeLine(l:indent . '{')
    call s:writeLine('')
    call s:writeText(a:impl)
    call s:writeLine(l:indent . '}')
endfunction

function! s:detectIntentation()
    let l:line = getline(s:searchPreviousClassElement())

    return substitute(l:line, '\S.*', '', '')
endfunction

function! s:searchPreviousClassElement()
    let l:declarationPattern = '\%(' . join([s:php_regex_member_line, s:php_regex_const_line, s:php_regex_func_line], '\)\|\(') .'\)'

    return search(l:declarationPattern, 'bn')
endfunction

function! s:writeLine(text)
    call append(s:getCurrentLine(), a:text)

    call s:forwardOneLine()
endfunction

function! s:forwardOneLine()
    call cursor(s:getCurrentLine() + 1, 0)
endfunction

function! s:getCurrentLine()
    return line('.')
endfunction

function! s:writeText(text)
    if 1 == &l:paste
        let l:backuppaste = 'paste'
    else
        let l:backuppaste = 'nopaste'
    endif
    setlocal paste

    exec 'normal! a' . a:text

    exec 'setlocal '.l:backuppaste
endfunction

function! s:echoWarning(message)
    echohl WarningMsg
    echomsg a:message
    echohl NONE
endfunction

function! s:echoError(message)
    echohl ErrorMsg
    echomsg a:message
    echohl NONE
endfunction

function! s:isInVisualBlockMode()
    return visualmode() == ''
endfunction

call refactoring_toolbox#vim#end_script()
