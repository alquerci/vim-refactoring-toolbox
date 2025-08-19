let s:php_regex_class_line = refactoring_toolbox#adapters#regex#class_line
let s:php_regex_const_line = refactoring_toolbox#adapters#regex#const_line
let s:SEARCH_NOT_FOUND = 0

call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#extract_constant#constant_extractor#execute(input, output, texteditor)
    let s:input = a:input
    let s:output = a:output
    let s:texteditor = a:texteditor

    try
        call s:validateMode()

        let l:answer = s:input.askQuestion('Name of new const?')
        let l:name = toupper(l:answer)

        let l:expression = s:readSelectedText()

        call s:replaceInCurrentClass(l:expression, 'self::' . l:name)
        call s:insertConst(l:name, l:expression)

        normal! `r
    catch /user_cancel/
        call s:output.echoWarning('You cancelled extract constant.')
    catch /unexpected_mode/
        call s:echoError('Extract constant doesn''t works in Visual line or Visual Block mode. Use Visual mode.')
    endtry
endfunction

function s:validateMode()
    if s:texteditor.isInVisualBlockMode()
        throw 'unexpected_mode'
    endif

    if s:texteditor.isInVisualLineMode()
        throw 'unexpected_mode'
    endif
endfunction

function s:readSelectedText()
    normal! mrgv"xy

    return @x
endfunction

function s:echoError(message)
    echohl ErrorMsg
    echomsg a:message
    echohl NONE
endfunction

function s:replaceInCurrentClass(search, replace)
    let [l:startLine, l:stopLine] = s:findCurrentClassLineRange()

    call s:texteditor.replaceStringWithTextBetweenLines(a:search, a:replace, l:startLine, l:stopLine)
endfunction

function s:findCurrentClassLineRange()
    try
        let l:backupPosition = getcurpos()

        call s:phpMoveToBeginOfClassBodyLine()

        let l:startLine = line('.')
        call searchpair('{', '', '}', 'W')
        let l:stopLine = line('.')

        call setpos('.', l:backupPosition)
    catch /class_body_not_found/
        let l:startLine = 1
        let l:stopLine = line('$')
    endtry

    return [l:startLine, l:stopLine]
endfunction

function s:insertConst(name, value)
    try
        let l:statement = s:makeStatement(a:name, a:value)

        call s:phpMoveToLastConstantLine()

        call s:insertStatement(l:statement)
    catch /class_constant_not_found/
        try
            call s:phpMoveToBeginOfClassBodyLine()

            call s:insertStatement(l:statement)

            call s:texteditor.appendText('')
        catch /class_body_not_found/
            call s:texteditor.moveToLine(2)

            call s:insertStatement(l:statement)

            call s:texteditor.appendText('')
        endtry
    endtry
endfunction

function s:makeStatement(name, value)
    let l:beforeConst = s:makeVisibility()

    if '' != l:beforeConst
        let l:beforeConst .= ' '
    endif

    return l:beforeConst.'const '.a:name.' = '.a:value.';'
endfunction

function s:makeVisibility()
    if s:isOutsideClass()
        return ''
    else
        return s:makeVisibilityInsideClass()
    endif
endfunction

function s:isOutsideClass()
    return search(s:php_regex_class_line, 'bWn') == s:SEARCH_NOT_FOUND
endfunction

function s:makeVisibilityInsideClass()
    let l:visibility = g:refactoring_toolbox_default_constant_visibility

    if 'public' == l:visibility
        return ''
    else
        return l:visibility
    endif
endfunction

function s:phpMoveToLastConstantLine()
    if search(s:php_regex_const_line, 'beW') == s:SEARCH_NOT_FOUND
        throw 'class_constant_not_found'
    endif
endfunction

function s:phpMoveToBeginOfClassBodyLine()
    if search(s:php_regex_class_line, 'beW') == s:SEARCH_NOT_FOUND
        throw 'class_body_not_found'
    endif

    call search('{', 'We')
endfunction

function s:insertStatement(statement)
    let l:firstLine = line('.') + 1

    call s:texteditor.appendText(a:statement)

    let l:totalLines = len(split(a:statement, '\n'))

    call s:texteditor.autoIndentLinesFromLine(l:totalLines, l:firstLine)
endfunction

call refactoring_toolbox#adapters#vim#end_script()
