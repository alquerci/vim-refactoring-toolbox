let s:php_regex_func_line = php_refactoring_toolbox#regex#func_line
let s:php_regex_member_line = php_refactoring_toolbox#regex#member_line
let s:php_regex_const_line = php_refactoring_toolbox#regex#const_line
let s:php_regex_local_var = php_refactoring_toolbox#regex#local_var

function! s:getVisibility(default)
    if g:vim_php_refactoring_auto_validate_visibility == 0
        return s:askForMethodVisibility(a:default)
    endif

    return a:default
endfunction

function! s:askForMethodVisibility(default)
    return s:askQuestion('Visibility?', a:default)
endfunction

function! php_refactoring_toolbox#extract_method#execute()
    try
        call s:validateMode()

        let l:name = s:askForMethodName()
        let l:visibility = s:getVisibility(g:vim_php_refactoring_default_method_visibility)
    catch /user_cancel/
        call s:echoWarning('You cancelled extract method.')

        return
    catch /unexpected_mode/
        call s:echoError('Extract method doesn''t works in Visual Block mode. Use Visual line or Visual mode.')

        return
    endtry

    " copy code to extract on @x and remove
    normal! gv"xs
    normal! mr
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

    " guess arguments used to call the new function
    let l:parameters = []
    " guess arguments of the new function
    let l:parametersSignature = []
    " guess variables that are mutated by the function
    let l:outputs = []
    for l:var in s:extractAllLocalVariables(@x)
        if match(l:beforeExtract, l:var . '\>') > 0
            call add(l:parameters, l:var)
            if @p =~ '[^,]*' . l:var . '\>[^,]*'
                call add(l:parametersSignature, substitute(matchstr(@p, '[^,]*' . l:var . '\>[^,]*'), '^\s*\(.\{-}\)\s*$', '\1', 'g'))
            else
                call add(l:parametersSignature, l:var)
            endif
        endif
        if match(l:afterExtract, l:var . '\>') > 0
            call add(l:outputs, l:var)
        endif
    endfor

    " add method call
    normal! `r
    let l:currentIndent = substitute(@x, '\S.*', '', '')
    " append semi-colon only if extracted code ends with new line
    let l:isInlineCode = "\<NL>" != @x[-1:]
    let l:endExpression = l:isInlineCode ? '' : ';'

    let l:methodCallExpression = printf('$this->%s(%s)%s', l:name, join(l:parameters, ', '), l:endExpression)
    if len(l:outputs) == 0
        call s:paste(l:currentIndent.l:methodCallExpression)
    elseif len(l:outputs) == 1
        call s:paste(l:currentIndent.l:outputs[0].' = '.l:methodCallExpression)
    else
        let l:leftSide = printf('list(%s)', join(l:outputs, ', '))
        call s:paste(l:currentIndent.l:leftSide.' = '.l:methodCallExpression)
    endif

    " add method
    let l:baseIndent = s:detectIntentation()
    let l:returnIndent = l:baseIndent.l:baseIndent
    let l:methodBody = @x
    if l:isInlineCode
        let l:return = ''
        let l:methodBody = 'return '.l:methodBody.';'
    elseif len(l:outputs) == 0
        let l:return = ''
    elseif len(l:outputs) == 1
        let l:return = "\<Enter>".l:returnIndent.'return ' . l:outputs[0] . ';'
    else
        let l:return = "\<Enter>".l:returnIndent.'return array(' . join(l:outputs, ', ') . ');'
    endif

    call s:PhpMoveEndOfFunction()

    let l:methodBody = substitute(l:methodBody, '^'.l:currentIndent, l:returnIndent, 'g')
    let l:methodBody = substitute(l:methodBody, '\n'.l:currentIndent, '\n'.l:returnIndent, 'g')
    call s:insertMethod(l:visibility, l:name, l:parametersSignature, l:methodBody . l:return)
    normal! `r
endfunction

function! s:validateMode()
    if s:isInVisualBlockMode()
        throw 'unexpected_mode'
    endif
endfunction

function! s:isInVisualBlockMode()
    return visualmode() == ''
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

function! s:moveToCurrentFunctionDefinition()
    call search(s:php_regex_func_line, 'bW')
endfunction

function! s:PhpMoveEndOfFunction()
    call search(s:php_regex_func_line, 'beW')
    call search('{', 'W')
    call searchpair('{', '', '}', 'W')
endfunction

function! s:insertMethod(modifiers, name, params, impl)
    let l:indent = s:detectIntentation()

    call s:writeLine('')
    call s:writeLine(l:indent . a:modifiers . ' function ' . a:name . '(' . join(a:params, ', ') . ')')
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
