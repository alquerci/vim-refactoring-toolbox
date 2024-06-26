let s:regex_after_word_boundary = refactoring_toolbox#adapters#regex#after_word_boundary

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
    return search('$', 'nW')
endfunction

function s:self.parseAssignmentRightSideOfLines(lines)
    let l:value = join(a:lines, "\<Enter>")

    let l:value = substitute(l:value, '[^=]*= ', '', '')

    return substitute(l:value, ';$', '', '')
endfunction

function s:self.replaceNextOccurenceOfVariableWithValue(variable, value)
    let l:variablePattern = a:variable.s:regex_after_word_boundary
    let [l:line, l:col] = searchpos(l:variablePattern)

    call s:texteditor.replacePatternWithTextBetweenLines(l:variablePattern, a:value, l:line, l:line)
endfunction

call refactoring_toolbox#adapters#vim#end_script()
