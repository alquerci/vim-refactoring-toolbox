let s:regex_func_line = refactoring_toolbox#adapters#ts_regex#func_line

call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#rename_variable#adapters#ts_language#make()
    return s:self
endfunction

let s:self = #{}

function s:self.parseVariable(word)
    return a:word
endfunction

function s:self.formatVariable(name)
    return a:name
endfunction

function s:self.findCurrentFunctionLineRange()
    let l:backupPosition = getcurpos()

    call search(s:regex_func_line, 'beW')
    let l:startLine = line('.')

    call search('{', 'Wc')
    call searchpair('{', '', '}', 'W')
    let l:stopLine = line('.')

    call setpos('.', l:backupPosition)

    return [l:startLine, l:stopLine]
endfunction

call refactoring_toolbox#adapters#vim#end_script()
