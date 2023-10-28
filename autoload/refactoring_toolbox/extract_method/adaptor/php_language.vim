call refactoring_toolbox#adaptor#vim#begin_script()

let s:regex_func_line = refactoring_toolbox#adaptor#regex#func_line
let s:regex_static_func = refactoring_toolbox#adaptor#regex#static_func
let s:regex_local_var = refactoring_toolbox#adaptor#regex#local_var
let s:regex_local_var_prefix = refactoring_toolbox#adaptor#regex#local_var_prefix
let s:regex_local_var_mutate = refactoring_toolbox#adaptor#regex#local_var_mutate
let s:regex_before_word_boudary = refactoring_toolbox#adaptor#regex#before_word_boudary
let s:regex_after_word_boudary = refactoring_toolbox#adaptor#regex#after_word_boudary
let s:regex_case_sensitive = refactoring_toolbox#adaptor#regex#case_sensitive
let s:NO_MATCH = -1

function refactoring_toolbox#extract_method#adaptor#php_language#make()
    return s:self
endfunction

let s:self = #{}

function s:self.positionIsInStaticMethod(position)
    let l:definitionLine = s:findDefinitionLineForFunctionWithPosition(a:position)

    return s:definitionAtLineIsStatic(l:definitionLine)
endfunction

function s:findDefinitionLineForFunctionWithPosition(position)
    let l:backupPosition = getcurpos()
    call setpos('.', a:position)

    let l:definitionLine = search(s:regex_func_line, 'bnW')

    call setpos('.', l:backupPosition)

    return l:definitionLine
endfunction

function s:definitionAtLineIsStatic(line)
    let l:content = getline(a:line)

    return match(l:content, s:regex_static_func) != s:NO_MATCH
endfunction

function s:self.getTopLineOfMethodWithPosition(position)
    let l:backupPosition = getcurpos()
    call setpos('.', a:position)

    call s:moveToCurrentFunctionDefinition()
    let l:topLine = s:getCurrentLine()

    call setpos('.', l:backupPosition)

    return l:topLine
endfunction

function s:self.getBottomLineOfMethodWithPosition(position)
    let l:backupPosition = getcurpos()

    call s:self.moveEndOfFunction()
    let l:bottomLine = s:getCurrentLine()

    call setpos('.', l:backupPosition)

    return l:bottomLine
endfunction

function s:self.moveEndOfFunction()
    call s:moveToCurrentFunctionDefinition()

    call s:moveToClosingBracket()
endfunction

function s:moveToClosingBracket()
    call search('{', 'W')
    call searchpair('{', '', '}', 'W')
endfunction

function s:moveToCurrentFunctionDefinition()
    call search(s:regex_func_line, 'bW')
endfunction

function s:self.getLocalVariablePattern()
    return s:regex_local_var
endfunction

function s:self.getMutatedLocalVariablePattern()
    return s:regex_local_var_mutate
endfunction

function s:self.variableExistsOnCode(variable, code)
    let l:pattern = s:regex_case_sensitive.s:makeLocalVariableNamePatternForName(a:variable)

    return match(a:code, l:pattern) != s:NO_MATCH
endfunction

function s:makeLocalVariableNamePatternForName(name)
    return '\%('.s:regex_local_var_prefix.'\)\@<='.s:makeVariableNamePatternForName(a:name)
endfunction

function s:makeVariableNamePatternForName(name)
    return s:regex_before_word_boudary.a:name.s:regex_after_word_boudary
endfunction

function s:self.codeHasReturn(code)
    let l:returnKeywordPattern = '^\_s*return\_s'
    let l:lines = split(a:code, "\n")

    return match(l:lines, l:returnKeywordPattern) != s:NO_MATCH
endfunction

function! s:makeMethodCall(definition)
    let l:context = s:prepareMethodCallContext(a:definition)

    let l:arguments = s:makeVariableList(a:definition.arguments)
    let l:arguments = join(l:arguments, ', ')

    let l:endExpression = a:definition.isInlineCall ? '' : ';'

    return printf('%s%s(%s)%s', l:context, a:definition.name, l:arguments, l:endExpression)
endfunction

function s:prepareMethodCallContext(definition)
    if a:definition.isStatic
        return 'self::'
    endif

    return '$this->'
endfunction

function! s:self.makeMethodCallStatement(codeToExtract, definition)
    let l:methodCall = s:makeMethodCall(a:definition)

    if s:self.codeHasReturn(a:codeToExtract)
        return s:makeReturnCode(l:methodCall)
    else
        let l:assigment = s:self.makeAssigment(a:definition)

        return l:assigment.l:methodCall
    endif
endfunction

function s:makeReturnCode(code)
    return 'return '.a:code
endfunction

function! s:self.makeAssigment(definition)
    let l:returnVariables = a:definition.returnVariables

    if len(l:returnVariables) == 0
        return ''
    elseif len(l:returnVariables) == 1
        return '$'.l:returnVariables[0].' = '
    else
        let l:returnVariables = s:makeVariableList(l:returnVariables)

        return printf('list(%s)', join(l:returnVariables, ', ')).' = '
    endif
endfunction

function s:self.makeInlineCodeToMethodBody(code)
    return 'return '.a:code.';'
endfunction

function s:self.makeReturnStatement(definition)
    let l:returnVariables = a:definition.returnVariables

    if len(l:returnVariables) == 1
        return 'return $'.l:returnVariables[0].';'
    else
        let l:returnVariables = s:makeVariableList(l:returnVariables)

        return 'return array('.join(l:returnVariables, ', ').');'
    endif
endfunction

function s:self.getMethodIndentationLevel()
    return 1
endfunction

function s:self.makeMethodHeaderLines(definition)
    let l:modifiers = s:prepareMethodModifiers(a:definition)
    let l:arguments = s:makeVariableList(a:definition.arguments)

    return [
        \ l:modifiers.' function '.a:definition.name.'('.join(l:arguments, ', ').')',
        \ '{',
    \ ]
endfunction

function s:self.makeMethodFooterLines(definition)
    return ['}']
endfunction

function s:self.prepareMethodBody(definition, codeToExtract)
    return a:codeToExtract
endfunction

function s:makeVariableList(names)
    let l:variables = []

    for l:name in a:names
        call add(l:variables, '$'.l:name)
    endfor

    return l:variables
endfunction

function s:prepareMethodModifiers(definition)
    if a:definition.isStatic
        return a:definition.visibility.' static'
    endif

    return a:definition.visibility
endfunction

function s:getCurrentLine()
    return line('.')
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
