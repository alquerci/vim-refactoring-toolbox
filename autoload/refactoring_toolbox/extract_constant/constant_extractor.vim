let s:php_regex_class_line = refactoring_toolbox#adaptor#regex#class_line
let s:php_regex_const_line = refactoring_toolbox#adaptor#regex#const_line

call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#extract_constant#constant_extractor#execute(input, texteditor)
    let s:input = a:input
    let s:texteditor = a:texteditor

    try
        call s:validateMode()

        let l:answer = s:input.askQuestion('Name of new const?')
        let l:name = toupper(l:answer)

        normal! mrgv"xy

        call s:replaceInCurrentClass(@x, 'self::' . l:name)
        call s:insertConst(l:name, @x)

        normal! `r
    catch /user_cancel/
        return
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

function s:echoError(message) " {{{
    echohl ErrorMsg
    echomsg a:message
    echohl NONE
endfunction

function s:replaceInCurrentClass(search, replace) " {{{
    let [l:startLine, l:stopLine] = s:findCurrentClassLineRange()

    call s:texteditor.replacePatternWithTextBetweenLines(a:search, a:replace, l:startLine, l:stopLine)
endfunction

function s:findCurrentClassLineRange()
    let l:backupPosition = getcurpos()

    call search(s:php_regex_class_line, 'beW')
    call search('{', 'W')
    let l:startLine = line('.')
    call searchpair('{', '', '}', 'W')
    let l:stopLine = line('.')

    call setpos('.', l:backupPosition)

    return [l:startLine, l:stopLine]
endfunction

function s:insertConst(name, value) " {{{
    if search(s:php_regex_const_line, 'beW') > 0
        call append(line('.'), 'const ' . a:name . ' = ' . a:value . ';')
    elseif search(s:php_regex_class_line, 'beW') > 0
        call search('{', 'W')
        call append(line('.'), 'const ' . a:name . ' = ' . a:value . ';')
        call append(line('.')+1, '')
    else
        call append(line('.'), 'const ' . a:name . ' = ' . a:value . ';')
    endif
    normal! j=1=
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
