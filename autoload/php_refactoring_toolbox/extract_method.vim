let s:php_regex_func_line = php_refactoring_toolbox#regex#func_line
let s:php_regex_member_line = php_refactoring_toolbox#regex#member_line
let s:php_regex_const_line = php_refactoring_toolbox#regex#const_line
let s:php_regex_local_var = php_refactoring_toolbox#regex#local_var
let s:NULL = 'NONE'

function! php_refactoring_toolbox#extract_method#execute()
    try
        call s:validateMode()

        let l:methodDefinition = #{name: s:NULL, visibility: s:NULL, arguments: [], returnVariables: []}

        let l:methodDefinition.name = s:askForMethodName()
        let l:methodDefinition.visibility = s:getVisibility(g:vim_php_refactoring_default_method_visibility)

        let l:codeToExtract = s:cutCodeToExtractAndMoveToInsertPosition()

        let l:methodInterface = s:extractMethodInterface(l:codeToExtract)
        let l:methodDefinition.arguments = l:methodInterface.argumentsSignature
        let l:methodDefinition.returnVariables = l:methodInterface.returnVariables
        let l:methodCallArguments = l:methodInterface.argumentsUsedToCall

        call s:insertMethodCall(l:codeToExtract, l:methodCallArguments, l:methodDefinition)
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

function! s:isInVisualBlockMode()
    return visualmode() == ''
endfunction

function! s:getVisibility(default)
    if g:vim_php_refactoring_auto_validate_visibility == 0
        return s:askForMethodVisibility(a:default)
    endif

    return a:default
endfunction

function! s:askForMethodVisibility(default)
    return s:askQuestion('Visibility?', a:default)
endfunction

function! s:askForMethodName()
    return s:askQuestion('Name of new method?')
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

function! s:cutCodeToExtractAndMoveToInsertPosition()
    normal! gv"xs

    return @x
endfunction

function! s:extractMethodInterface(codeToExtract)
    let l:positionToInsertCall = getcurpos()

    let l:methodInterface = #{argumentsUsedToCall: [], argumentsSignature: [], returnVariables: []}

    let l:middleLine = line('.')

    call s:moveToCurrentFunctionDefinition()
    let l:startLine = line('.')

    " move to current function argument definition
    call search('(', 'W')
    " copy function arguments on @p
    normal! "pyi(

    " move to end of the current function
    call search('{', 'W')
    call searchpair('{', '', '}', 'W')
    let l:stopLine = line('.')

    " collect content of the function that will be
    let l:beforeExtract = join(getline(l:startLine, l:middleLine-1))
    let l:afterExtract  = join(getline(l:middleLine, l:stopLine))

    for l:var in s:extractAllLocalVariables(a:codeToExtract)
        if match(l:beforeExtract, l:var . '\>') > 0
            call add(l:methodInterface.argumentsUsedToCall, l:var)
            if @p =~ '[^,]*' . l:var . '\>[^,]*'
                call add(l:methodInterface.argumentsSignature, substitute(matchstr(@p, '[^,]*' . l:var . '\>[^,]*'), '^\s*\(.\{-}\)\s*$', '\1', 'g'))
            else
                call add(l:methodInterface.argumentsSignature, l:var)
            endif
        endif
        if match(l:afterExtract, l:var . '\>') > 0
            call add(l:methodInterface.returnVariables, l:var)
        endif
    endfor

    call setpos('.', l:positionToInsertCall)

    return l:methodInterface
endfunction

function! s:insertMethodCall(codeToExtract, arguments, definition)
    let l:positionToInsertCall = getcurpos()

    let l:currentIndent = s:getBaseIndentOfText(a:codeToExtract)

    " append semi-colon only if extracted code ends with new line
    let l:endExpression = s:isInlineCode(a:codeToExtract) ? '' : ';'

    let l:methodCallExpression = printf('$this->%s(%s)%s', a:definition.name, join(a:arguments, ', '), l:endExpression)
    if len(a:definition.returnVariables) == 0
        call s:paste(l:currentIndent.l:methodCallExpression)
    elseif len(a:definition.returnVariables) == 1
        call s:paste(l:currentIndent.a:definition.returnVariables[0].' = '.l:methodCallExpression)
    else
        let l:leftSide = printf('list(%s)', join(a:definition.returnVariables, ', '))
        call s:paste(l:currentIndent.l:leftSide.' = '.l:methodCallExpression)
    endif

    call setpos('.', l:positionToInsertCall)
endfunction

function! s:isInlineCode(codeToExtract)
    return "\<NL>" != a:codeToExtract[-1:]
endfunction

function! s:getBaseIndentOfText(text)
    return substitute(a:text, '\S.*', '', '')
endfunction

function! s:moveToCurrentFunctionDefinition()
    call search(s:php_regex_func_line, 'bW')
endfunction

function! s:addMethod(codeToExtract, definition)
    let l:positionToInsertCall = getcurpos()

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

    call setpos('.', l:positionToInsertCall)
endfunction

function! s:moveEndOfFunction()
    call search(s:php_regex_func_line, 'beW')
    call search('{', 'W')
    call searchpair('{', '', '}', 'W')
endfunction

function! s:insertMethod(modifiers, methodName, params, impl)
    let l:indent = s:detectIntentation()

    call s:writeLine('')
    call s:writeLine(l:indent . a:modifiers . ' function ' . a:methodName . '(' . join(a:params, ', ') . ')')
    call s:writeLine(l:indent . '{')
    call s:writeLine('')
    call s:paste(a:impl)
    call s:writeLine(l:indent . '}')
endfunction

function! s:detectIntentation()
    let l:line = getline(s:searchLineOfPreviousClassDeclaration())

    return substitute(l:line, '\S.*', '', '')
endfunction

function! s:searchLineOfPreviousClassDeclaration()
    let l:declarationPattern = '\%(' . join([s:php_regex_member_line, s:php_regex_const_line, s:php_regex_func_line], '\)\|\(') .'\)'

    return search(l:declarationPattern, 'bn')
endfunction

function! s:writeLine(text)
    call append(line('.'), a:text)

    call s:forwardOneLine()
endfunction

function! s:forwardOneLine()
    call cursor(line('.') + 1, 0)
endfunction

function! s:paste(text)
    if 1 == &l:paste
        let l:backuppaste = 'paste'
    else
        let l:backuppaste = 'nopaste'
    endif
    setlocal paste

    exec 'normal! a' . a:text

    exec 'setlocal '.l:backuppaste
endfunction

function! s:extractAllLocalVariables(haystack)
    let l:result = []
    let l:matchPos = match(a:haystack, s:php_regex_local_var, 0)

    while l:matchPos > 0
        let l:str = matchstr(a:haystack, s:php_regex_local_var, l:matchPos)
        if index(l:result, l:str) < 0
            call add(l:result, l:str)
        endif
        let l:matchPos = match(a:haystack, s:php_regex_local_var, l:matchPos + strlen(l:str))
    endwhile

    return l:result
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
