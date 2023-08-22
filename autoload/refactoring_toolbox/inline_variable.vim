call refactoring_toolbox#vim#begin_script()

let s:CURRENT_BUFFER = '%'
let s:regex_after_word_boudary = refactoring_toolbox#regex#after_word_boudary

function! refactoring_toolbox#inline_variable#execute()
    let l:variable = s:readVariableOnCurrentPosition()
    let l:value = s:readValueOnCurrentPosition()

    call s:removeCurrentLine()

    call s:searchAndReplaceVariableWithValue(l:variable, l:value)
endfunction

function! s:readVariableOnCurrentPosition()
    return '$'.expand('<cword>')
endfunction

function! s:readValueOnCurrentPosition()
    let l:value = getbufline(s:CURRENT_BUFFER, s:getCurrentLine())[0]
    let l:value = substitute(l:value, '[^=]*= ', '', '')

    return substitute(l:value, ';$', '', '')
endfunction

function! s:searchAndReplaceVariableWithValue(variable, value)
    let l:variablePattern = a:variable.s:regex_after_word_boudary
    let [l:line, l:col] = searchpos(l:variablePattern)

    execute l:line.','.l:line.':s/'.l:variablePattern.'/'.a:value.'/'
endfunction

function! s:removeCurrentLine()
    call deletebufline(s:CURRENT_BUFFER, s:getCurrentLine())
endfunction

function! s:getCurrentLine()
    return line('.')
endfunction

call refactoring_toolbox#vim#end_script()
