let s:regex_after_word_boundary = refactoring_toolbox#adapters#regex#after_word_boundary
let s:regex_func_line = refactoring_toolbox#adapters#regex#func_line

call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#inline_variable#adapters#php_language#make(texteditor)
    let s:texteditor = a:texteditor

    return s:self
endfunction

let s:self = #{}

function s:self.readVariableOnCurrentPosition()
    return '$'.expand('<cword>')
endfunction

function s:self.findEndExpressionLineFromCurrentPosition()
    return search(';', 'nW')
endfunction

function s:self.parseAssignmentRightSideOfLines(lines)
    let l:value = join(a:lines, "\<Enter>")

    let l:value = substitute(l:value, '[^=]*= ', '', '')

    return substitute(l:value, ';$', '', '')
endfunction

function s:self.replaceNextOccurenceOfVariableWithValue(variable, value)
    let l:variablePattern = a:variable.s:regex_after_word_boundary
    let l:line = search(l:variablePattern)

    call s:texteditor.replacePatternWithTextBetweenLines(l:variablePattern, a:value, l:line, l:line)
endfunction

function s:self.hasNextOccurenceOfVariable(variable)
    let l:functionEndLine = s:searchFunctionEndLineFromPosition(getcurpos())

    let l:variablePattern = a:variable.s:regex_after_word_boundary
    let l:nextOccurenceLine = search(l:variablePattern, 'nW')

    if 0 == l:nextOccurenceLine
        return v:false
    else
        return l:functionEndLine > l:nextOccurenceLine
    endif
endfunction

function s:searchFunctionEndLineFromPosition(position)
    call setpos('.', a:position)
    call s:moveEndOfFunction()
    let l:endLine = s:getCurrentLine()
    call setpos('.', a:position)

    return l:endLine
endfunction

function s:moveEndOfFunction()
    call s:moveToCurrentFunctionDefinition()

    call s:moveToClosingBracket()
endfunction

function s:moveToCurrentFunctionDefinition()
    call search(s:regex_func_line, 'bW')
endfunction

function s:moveToClosingBracket()
    call search('{', 'W')
    call searchpair('{', '', '}', 'W')
endfunction

function s:getCurrentLine()
    return line('.')
endfunction

call refactoring_toolbox#adapters#vim#end_script()
