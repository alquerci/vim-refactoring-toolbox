let s:php_regex_func_line = php_refactoring_toolbox#regex#func_line
let s:php_regex_member_line = php_refactoring_toolbox#regex#member_line
let s:php_regex_const_line = php_refactoring_toolbox#regex#const_line
let s:php_regex_local_var = php_refactoring_toolbox#regex#local_var
let s:php_regex_local_var_mutate = php_refactoring_toolbox#regex#local_var_mutate
let s:NULL = 'NONE'

function! php_refactoring_toolbox#extract_method#execute()
    try
        call s:validateMode()

        let l:methodDefinition = #{name: s:NULL, visibility: s:NULL, arguments: [], returnVariables: []}

        let l:methodDefinition.name = s:askForMethodName()
        let l:methodDefinition.visibility = s:getVisibility(g:vim_php_refactoring_default_method_visibility)

        let l:codeToExtract = s:cutCodeToExtractAndMoveToInsertPosition()

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
    return s:askQuestion('Name of new method?')
endfunction

function! s:getVisibility(default)
    if g:vim_php_refactoring_auto_validate_visibility == 0
        return s:askForMethodVisibility(a:default)
    endif

    return a:default
endfunction

function! s:cutCodeToExtractAndMoveToInsertPosition()
    normal! gv"xs

    return @x
endfunction

function! s:extractArguments(codeToExtract)
    let l:methodCodeBefore = s:collectMethodCodeBeforeCurrentLine()

    return s:extractVariablesPresentInBothCode(a:codeToExtract, l:methodCodeBefore)
endfunction

function! s:extractReturnVariables(codeToExtract)
    let l:methodCodeAfter = s:collectMethodCodeAfterCurrentLine()

    return s:extractMutatedVariablesUsedAfter(a:codeToExtract, l:methodCodeAfter)
endfunction

function! s:insertMethodCall(codeToExtract, definition)
    let l:backupPosition = getcurpos()

    let l:currentIndent = s:getBaseIndentOfText(a:codeToExtract)

    " append semi-colon only if extracted code ends with new line
    let l:endExpression = s:isInlineCode(a:codeToExtract) ? '' : ';'

    let l:methodCallExpression = printf('$this->%s(%s)%s', a:definition.name, join(a:definition.arguments, ', '), l:endExpression)
    if len(a:definition.returnVariables) == 0
        call s:writeText(l:currentIndent.l:methodCallExpression)
    elseif len(a:definition.returnVariables) == 1
        call s:writeText(l:currentIndent.a:definition.returnVariables[0].' = '.l:methodCallExpression)
    else
        let l:leftSide = printf('list(%s)', join(a:definition.returnVariables, ', '))
        call s:writeText(l:currentIndent.l:leftSide.' = '.l:methodCallExpression)
    endif

    call setpos('.', l:backupPosition)
endfunction

function! s:addMethod(codeToExtract, definition)
    let l:backupPosition = getcurpos()

    let l:baseIndent = s:detectIntentation()
    let l:returnIndent = l:baseIndent.l:baseIndent
    let l:methodBody = a:codeToExtract
    if s:isInlineCode(a:codeToExtract)
        let l:return = ''
        let l:methodBody = 'return '.l:methodBody.';'
    elseif len(a:definition.returnVariables) == 0
        let l:return = ''
    elseif len(a:definition.returnVariables) == 1
        let l:return = "\<Enter>".l:returnIndent.'return ' . a:definition.returnVariables[0] . ';'
    else
        let l:return = "\<Enter>".l:returnIndent.'return array(' . join(a:definition.returnVariables, ', ') . ');'
    endif

    call s:moveEndOfFunction()

    let l:currentIndent = s:getBaseIndentOfText(a:codeToExtract)
    let l:methodBody = substitute(l:methodBody, '^'.l:currentIndent, l:returnIndent, 'g')
    let l:methodBody = substitute(l:methodBody, '\n'.l:currentIndent, '\n'.l:returnIndent, 'g')
    call s:insertMethod(a:definition.visibility, a:definition.name, a:definition.arguments, l:methodBody . l:return)

    call setpos('.', l:backupPosition)
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
    return s:askQuestion('Visibility?', a:default)
endfunction

function! s:askQuestion(question, default = '')
    let l:prompt = s:makeQuestionPrompt(a:question, a:default)

    return s:sendQuestionAndCollectAnswer(l:prompt, a:default)
endfunction

function! s:makeQuestionPrompt(question, default)
    return a:question.' ["'.a:default.'"] '
endfunction

function! s:sendQuestionAndCollectAnswer(prompt, default)
    let l:cancelMarker = "//<Esc>"
    let l:defaultMarker = ''

    let l:answer = inputdialog(a:prompt, l:defaultMarker, l:cancelMarker)

    if l:cancelMarker == l:answer
        throw 'user_cancel'
    endif

    return l:defaultMarker == l:answer ? a:default : l:answer
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
    return match(a:code, a:variable . '\>') > 0
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

    while l:matchPos > 0
        let l:str = matchstr(a:haystack, a:stringPattern, l:matchPos)
        if index(l:strings, l:str) < 0
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
