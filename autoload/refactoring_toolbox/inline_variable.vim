call refactoring_toolbox#adaptor#vim#begin_script()

let s:CURRENT_BUFFER = '%'
let s:regex_after_word_boudary = refactoring_toolbox#adaptor#regex#after_word_boudary

function refactoring_toolbox#inline_variable#execute()
    let l:variable = s:readVariableOnCurrentPosition()
    let l:value = s:readValueOnCurrentPosition()

    call s:removeExpressionOnCurrentPosition()

    call s:searchAndReplaceVariableWithValue(l:variable, l:value)
endfunction

function s:readVariableOnCurrentPosition()
    return '$'.expand('<cword>')
endfunction

function s:readValueOnCurrentPosition()
    let l:endLine = search(';', 'nW')
    let l:lines = getline(s:getCurrentLine(), l:endLine)

    let l:value = join(l:lines, "\<Enter>")

    let l:value = substitute(l:value, '[^=]*= ', '', '')

    return substitute(l:value, ';$', '', '')
endfunction

function s:searchAndReplaceVariableWithValue(variable, value)
    let l:variablePattern = a:variable.s:regex_after_word_boudary
    let [l:line, l:col] = searchpos(l:variablePattern)
    let l:value = escape(a:value, '/')

    execute l:line.','.l:line.':s/'.l:variablePattern.'/'.l:value.'/'
endfunction

function s:removeExpressionOnCurrentPosition()
    let l:startLine = s:getCurrentLine()
    let l:endLine = search(';', 'nW')

    call deletebufline(s:CURRENT_BUFFER, l:startLine, l:endLine)
endfunction

function s:getCurrentLine()
    return line('.')
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
