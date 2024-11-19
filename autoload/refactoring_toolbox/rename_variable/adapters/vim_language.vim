let s:regex_func_line = '^function\s'
let s:regex_after_word_boundary = refactoring_toolbox#adapters#regex#after_word_boundary
let s:regex_case_sensitive = refactoring_toolbox#adapters#regex#case_sensitive

call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#rename_variable#adapters#vim_language#make()
    return s:self
endfunction

let s:self = #{}

function s:self.parseVariable(word)
    return substitute(a:word, '^l:*', '', '')
endfunction

function s:self.formatVariable(name)
    return 'l:'.a:name
endfunction

function s:self.makeVariablePattern(name)
    return s:regex_case_sensitive.s:self.formatVariable(a:name).s:regex_after_word_boundary
endfunction

function s:self.makeVariableDefinitionPattern(name)
    return refactoring_toolbox#adapters#regex#makeLocalVariableDefinition(a:name)
endfunction

function s:self.findCurrentFunctionLineRange()
    let l:backupPosition = getcurpos()

    call search(s:regex_func_line, 'beW')
    let l:startLine = line('.')

    call searchpair('function', '', 'endfunction', 'W')
    let l:endLine = line('.')

    call setpos('.', l:backupPosition)

    return [l:startLine, l:endLine]
endfunction

function s:self.findParentScopeLineRange()
    return s:self.findCurrentFunctionLineRange()
endfunction

function s:self.findCurrentFunctionDefinitionLineRange()
    let l:backupPosition = getcurpos()

    call search(s:regex_func_line, 'becW')
    let l:startLine = line('.')
    let l:endLine = line('.')

    call setpos('.', l:backupPosition)

    return [l:startLine, l:endLine]
endfunction

call refactoring_toolbox#adapters#vim#end_script()
