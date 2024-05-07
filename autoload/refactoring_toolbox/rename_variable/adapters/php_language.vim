let s:regex_func_line = refactoring_toolbox#adapters#regex#func_line
let s:regex_after_word_boundary = refactoring_toolbox#adapters#regex#after_word_boudary
let s:regex_case_sensitive = refactoring_toolbox#adapters#regex#case_sensitive

call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#rename_variable#adapters#php_language#make()
    return s:self
endfunction

let s:self = #{}

function s:self.parseVariable(word)
    return substitute(a:word, '^\$*', '', '')
endfunction

function s:self.formatVariable(name)
    return '$'.a:name
endfunction

function s:self.makeVariablePattern(name)
    return s:regex_case_sensitive.s:self.formatVariable(a:name).s:regex_after_word_boundary
endfunction

function s:self.findCurrentFunctionLineRange()
    let l:backupPosition = getcurpos()

    call search(s:regex_func_line, 'beW')
    let l:startLine = line('.')

    call search('{', 'W')
    call searchpair('{', '', '}', 'W')
    let l:stopLine = line('.')

    call setpos('.', l:backupPosition)

    return [l:startLine, l:stopLine]
endfunction

call refactoring_toolbox#adapters#vim#end_script()
