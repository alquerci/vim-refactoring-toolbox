let s:CURRENT_BUFFER = '%'

function! php_refactoring_toolbox#inline_variable#execute()
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
    let [l:line, l:col] = searchpos(a:variable)

    execute l:line.','.l:line.':s/'.a:variable.'/'.a:value.'/'
endfunction

function! s:removeCurrentLine()
    call deletebufline(s:CURRENT_BUFFER, s:getCurrentLine())
endfunction

function! s:getCurrentLine()
    return line('.')
endfunction
