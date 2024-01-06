let s:regex_after_word_boudary = refactoring_toolbox#adaptor#regex#after_word_boudary

call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#inline_variable#adapters#php_language#make()
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
    let l:variablePattern = a:variable.s:regex_after_word_boudary
    let [l:line, l:col] = searchpos(l:variablePattern)
    let l:value = escape(a:value, '/')

    execute l:line.','.l:line.':s/'.l:variablePattern.'/'.l:value.'/'
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
