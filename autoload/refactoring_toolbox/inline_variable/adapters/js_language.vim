let s:regex_after_word_boundary = refactoring_toolbox#adapters#regex#after_word_boundary
let s:SEARCH_NOT_FOUND = 0
let s:regex_assignment_left_side_with_equal = '^[^=]*= '
let s:pairs = {'[': ']', '{': '}', '(': ')'}

call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#inline_variable#adapters#js_language#make(texteditor)
    let s:texteditor = a:texteditor

    return s:self
endfunction

let s:self = #{}

function s:self.readVariableOnCurrentPosition()
    return expand('<cword>')
endfunction

function s:self.findEndExpressionLineFromCurrentPosition()
    let l:backupPosition = getcurpos()

    let l:lineLastChar = s:getLastCharOfCurrentLine()

    if s:isMultilineAssignmentWithPair(l:lineLastChar)
        let l:endLine = s:searchEndLineForPairOfChars(l:lineLastChar)
    elseif '`' == l:lineLastChar
        let l:endLine = s:searchLineOfNextBacktick()
    elseif '\' == l:lineLastChar
        let l:endLine = s:searchNextLineNotEndingWithBackSlash()
    else
        let l:endLine = line('.')
    endif

    call setpos('.', l:backupPosition)

    return l:endLine
endfunction

function s:getLastCharOfCurrentLine()
    return getline('.')[-1:]
endfunction

function s:isMultilineAssignmentWithPair(start)
    return has_key(s:pairs, a:start)
        && s:SEARCH_NOT_FOUND != search(s:escapePair(a:start).'$', 'nW')
endfunction

function s:searchEndLineForPairOfChars(start)
    let l:end = get(s:pairs, a:start)

    call search(s:escapePair(a:start).'$', 'W')

    return searchpair(s:escapePair(a:start), '', s:escapePair(l:end), 'nW')
endfunction

function s:escapePair(string)
    return escape(a:string, '[]')
endfunction

function s:searchLineOfNextBacktick()
    let l:backupPosition = getcurpos()

    call search('`', 'W')

    let l:line = search('`$', 'Wn')

    call setpos('.', l:backupPosition)

    return l:line
endfunction

function s:searchNextLineNotEndingWithBackSlash()
    let l:backupPosition = getcurpos()

    call s:moveToNextLine()

    while '\' == s:getLastCharOfCurrentLine()
        call s:moveToNextLine()
    endwhile

    let l:line = line('.')

    call setpos('.', l:backupPosition)

    return l:line
endfunction

function s:moveToNextLine()
    call cursor(line('.') + 1, 0)
endfunction

function s:self.parseAssignmentRightSideOfLines(lines)
    let l:value = join(a:lines, "\<Enter>")

    let l:value = substitute(l:value, s:regex_assignment_left_side_with_equal, '', '')

    return substitute(l:value, ';$', '', '')
endfunction

function s:self.replaceNextOccurenceOfVariableWithValue(variable, value)
    let l:variablePattern = a:variable.s:regex_after_word_boundary
    let [l:line, l:col] = searchpos(l:variablePattern)

    call s:texteditor.replacePatternWithTextBetweenLines(l:variablePattern, a:value, l:line, l:line)
endfunction

call refactoring_toolbox#adapters#vim#end_script()
