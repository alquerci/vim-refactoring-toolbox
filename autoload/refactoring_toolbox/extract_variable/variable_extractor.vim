call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#extract_variable#variable_extractor#execute(input, language)
    let s:input = a:input
    let s:language = a:language

    try
        if visualmode() != 'v'
            call s:echoError('Extract variable only works in Visual mode, not in Visual Line or Visual block')
            return
        endif

        let l:name = s:input.askQuestion('Name of new variable?')

        " add marker
        let l:backupPosition = getcurpos()

        let l:codeToExtract = s:cutCodeToExtractAndMoveToInsertPosition()

        call s:insertVariable(l:name)

        " go to start on selection
        call setpos('.', l:backupPosition)

        call s:writeDefinition(l:name, l:codeToExtract)

        " go to start on selection
        call setpos('.', l:backupPosition)
    catch /user_cancel/
        return
    endtry
endfunction

function s:echoError(message)
    echohl ErrorMsg
    echomsg a:message
    echohl NONE
endfunction

function s:cutCodeToExtractAndMoveToInsertPosition()
    normal! gv"xs

    return @x
endfunction

function s:insertVariable(name)
    call s:writeText(s:language.makeVariableUsage(a:name))
endfunction

function s:writeText(text)
    if 1 == &l:paste
        let l:backuppaste = 'paste'
    else
        let l:backuppaste = 'nopaste'
    endif
    setlocal paste

    exec 'normal! a' . a:text

    exec 'setlocal '.l:backuppaste
endfunction

function s:writeDefinition(name, value)
    call s:backwardOneLine()
    call s:moveOnTopOfExpression()

    call s:writeEmptyNewLine()

    let l:indent = s:getIndentOfNextNonBlankLine()

    call s:writeText(l:indent.s:language.makeAssignation(a:name, a:value))

    call s:writeEmptyNewLine()
endfunction

function s:writeEmptyNewLine()
    call append(line('.'), '')
    call s:forwardOneLine()
endfunction

function s:backwardOneLine()
    call cursor(line('.') - 1, 0)
endfunction

function s:moveOnTopOfExpression()
    while s:currentLineEndsWithCommaOrFunctionCallOrBracket()
        call s:backwardOneLine()
    endwhile
endfunction

function s:currentLineEndsWithCommaOrFunctionCallOrBracket()
    return s:currentLineEndsWith(',')
        \ || s:currentLineEndsWith(')')
        \ || s:currentLineEndsWith('[')
        \ || s:currentLineEndsWith(']')
endfunction

function s:currentLineEndsWith(char)
    return a:char == trim(getline(line('.')))[-1:]
endfunction

function s:forwardOneLine()
    call cursor(line('.') + 1, 0)
endfunction

function s:getIndentOfNextNonBlankLine()
    return s:getBaseIndentOfText(getline(nextnonblank(line('.'))))
endfunction

function s:getBaseIndentOfText(text)
    return substitute(a:text, '\S.*', '', '')
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
