let s:regex_func_line = refactoring_toolbox#adapters#js_regex#func_line
let s:regex_after_word_boundary = refactoring_toolbox#adapters#regex#after_word_boundary
let s:regex_before_word_boundary = refactoring_toolbox#adapters#regex#before_word_boundary
let s:regex_case_sensitive = refactoring_toolbox#adapters#regex#case_sensitive

call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#rename_variable#adapters#js_language_common#make()
    return s:self
endfunction

let s:self = #{}

function s:self.parseVariable(word)
    return a:word
endfunction

function s:self.formatVariable(name)
    return a:name
endfunction

function s:self.makeVariablePattern(name)
    return s:regex_case_sensitive.s:regex_before_word_boundary.a:name.s:regex_after_word_boundary
endfunction

function s:self.makeVariableDefinitionPattern(name)
    return refactoring_toolbox#adapters#js_regex#makeLocalVariableDefinition(a:name)
endfunction

function s:self.findCurrentFunctionLineRangeWithPattern(pattern)
    let l:backupPosition = getcurpos()

    call search(a:pattern, 'beW')
    let l:startLine = line('.')

    call search('{', 'Wc')
    call searchpair('{', '', '}', 'W')
    let l:endLine = line('.')

    call setpos('.', l:backupPosition)

    return [l:startLine, l:endLine]
endfunction

function s:self.findParentScopeLineRangeWithPattern(pattern)
    let [l:startLine, l:endLine] = s:self.findCurrentFunctionLineRangeWithPattern(a:pattern)

    let l:backupPosition = getcurpos()

    call search(a:pattern, 'beW')
    call cursor(line('.') - 1, 0)

    let [l:parentStartLine, l:parentEndLine] = s:self.findCurrentFunctionLineRangeWithPattern(a:pattern)

    call setpos('.', l:backupPosition)

    if l:startLine > l:parentEndLine
        return [l:startLine, l:endLine]
    else
        return [l:parentStartLine, l:parentEndLine]
    endif
endfunction

function s:self.findCurrentFunctionDefinitionLineRangeWithPattern(pattern)
    let l:backupPosition = getcurpos()

    call search(a:pattern, 'becW')
    let l:startLine = line('.')
    call search('{', 'Wc')
    let l:endLine = line('.')

    call setpos('.', l:backupPosition)

    return [l:startLine, l:endLine]
endfunction

call refactoring_toolbox#adapters#vim#end_script()
