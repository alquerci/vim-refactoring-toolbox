call refactoring_toolbox#adaptor#vim#begin_script()

let s:regex_before_word_boudary = refactoring_toolbox#adaptor#regex#before_word_boudary
let s:regex_after_word_boudary = refactoring_toolbox#adaptor#regex#after_word_boudary

let s:regex_func_line = '=>'
let s:regex_var_name = '\w\+'
let s:NO_MATCH = -1

function refactoring_toolbox#extract_method#adaptor#js_language#make()
    return s:self
endfunction

let s:self = #{}

function s:self.positionIsInStaticMethod(position)
    return v:false
endfunction

function s:self.getTopLineOfMethodWithPosition(position)
    return s:searchLineBackwardWithPatternFromPosition(s:regex_func_line, a:position)
endfunction

function s:self.getBottomLineOfMethodWithPosition(position)
    let l:topLine = s:self.getTopLineOfMethodWithPosition(a:position)

    return s:getLineOfClosingBracketFromLine(l:topLine)
endfunction

function s:self.moveEndOfFunction()
    let l:position = getcurpos()

    let l:line = s:self.getBottomLineOfMethodWithPosition(l:position)

    call s:moveToLineFromPosition(l:line, l:position)
endfunction

function s:self.getLocalVariablePattern()
    return s:regex_var_name
endfunction

function s:self.getMutatedLocalVariablePattern()
    return '\%('.s:regex_var_name.'\)\(\_s*=\)\@='
endfunction

function s:self.variableExistsOnCode(variable, code)
    let l:pattern = s:makePatternForVariableName(a:variable)

    return match(a:code, l:pattern) != s:NO_MATCH
endfunction

function s:makePatternForVariableName(name)
    return s:regex_before_word_boudary.a:name.s:regex_after_word_boudary
endfunction

function s:self.codeHasReturn(code)
    return match(a:code, 'return ') != s:NO_MATCH
endfunction

function s:self.makeInlineCodeToMethodBody(code)
    return 'return '.a:code
endfunction

function s:self.prepareMethodBody(definition, codeToExtract)
    return a:codeToExtract
endfunction

function s:self.makeReturnStatement(definition)
    if 0 < len(a:definition.returnVariables)
        return 'return '.s:makeReturnVariables(a:definition)
    else
        return ''
    endif
endfunction

function s:self.getMethodIndentationLevel()
    return 0
endfunction

function s:self.makeMethodCallStatement(codeToExtract, definition)
    let l:assignment = s:makeAssignment(a:definition)
    let l:arguments = s:makeArguments(a:definition)

    if s:self.codeHasReturn(a:codeToExtract)
        let l:assignment = 'return '
    endif

    return l:assignment.a:definition.name.'('.l:arguments.')'
endfunction

function s:self.makeMethodHeaderLines(definition)
    let l:arguments = s:makeArguments(a:definition)

    return [
        \ 'const '.a:definition.name.' = ('.l:arguments.') => {',
    \ ]
endfunction

function s:self.makeMethodFooterLines(definition)
    return ['}']
endfunction

function s:makeArguments(definition)
    return join(a:definition.arguments, ', ')
endfunction

function s:makeAssignment(definition)
    if 0 < len(a:definition.returnVariables)
        return 'const '.s:makeReturnVariables(a:definition).' = '
    else
        return ''
    endif
endfunction

function s:makeReturnVariables(definition)
    if 1 < len(a:definition.returnVariables)
        return '['.join(a:definition.returnVariables, ', ').']'
    endif

    return join(a:definition.returnVariables, '')
endfunction

function s:getLineOfClosingBracketFromLine(line)
    let l:backupPosition = getcurpos()

    call s:moveToLineFromPosition(a:line, l:backupPosition)

    call search('{', 'W')

    let l:line = searchpair('{', '', '}', 'Wn')

    call setpos('.', l:backupPosition)

    return l:line
endfunction

function s:moveToLineFromPosition(line, position)
    let l:position = a:position
    let l:position[1] = a:line
    let l:position[2] = 0

    call setpos('.', l:position)
endfunction

function s:searchLineBackwardWithPatternFromPosition(pattern, position)
    let l:backupPosition = getcurpos()

    call setpos('.', a:position)
    let l:line = search(a:pattern, 'Wnb')

    call setpos('.', l:backupPosition)

    return l:line
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
