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

function refactoring_toolbox#extract_method#adaptor#php_language#make(position)
    let s:position = a:position

    return s:self
endfunction

let s:self = #{}

function s:self.positionIsInStaticMethod(position)
    let l:definitionLine = s:findDefinitionLineForFunctionWithPosition(a:position)

    return s:definitionAtLineIsStatic(l:definitionLine)
endfunction

function s:findDefinitionLineForFunctionWithPosition(position)
    call s:position.moveToPosition(a:position)

    let l:definitionLine = search(s:regex_func_line, 'bnW')

    call s:position.backToPreviousPosition()

    return l:definitionLine
endfunction

function s:definitionAtLineIsStatic(line)
    let l:content = getline(a:line)

    return match(l:content, s:regex_static_func) != s:NO_MATCH
endfunction

function s:self.getTopLineOfMethodWithPosition(position)
    let l:topPosition = s:self.getTopPositionOfMethodWithPosition(a:position)

    return s:position.getLineOfPosition(l:topPosition)
endfunction

function s:self.getTopPositionOfMethodWithPosition(position)
    call s:position.moveToPosition(a:position)

    call s:moveToCurrentFunctionDefinition()
    let l:topPosition = s:position.getCurrentPosition()

    call s:position.backToPreviousPosition()

    return l:topPosition
endfunction

function s:self.getBottomLineOfMethodWithPosition(position)
    call s:position.moveToPosition(a:position)

    call s:self.moveEndOfFunction()
    let l:bottomLine = s:position.getCurrentLine()

    call s:position.backToPreviousPosition()

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

function s:self.makeMethodCallStatement(definition, codeToExtract)
    let l:methodCall = s:makeMethodCall(a:definition)

    if s:self.codeHasReturn(a:codeToExtract)
        return s:makeReturnCode(l:methodCall)
    else
        let l:assigment = s:makeAssigment(a:definition)

        return l:assigment.l:methodCall
    endif
endfunction

function s:makeMethodCall(definition)
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

function s:makeReturnCode(code)
    return 'return '.a:code
endfunction

function s:makeAssigment(definition)
    if 0 < len(a:definition.returnVariables)
        let l:returnVariables = s:makeExpressionForAssigningVariables(a:definition.returnVariables)

        return l:returnVariables.' = '
    else
        return ''
    endif
endfunction

function s:makeExpressionForAssigningVariables(variableNames)
    let l:variables = s:makeVariableList(a:variableNames)

    if 1 == len(l:variables)
        return join(l:variables, '')
    else
        return 'list('.join(l:variables, ', ').')'
    endif
endfunction

function s:self.makeMethodHeaderLines(definition)
    let l:modifiers = s:prepareMethodModifiers(a:definition)
    let l:arguments = s:makeVariableList(a:definition.arguments)

    return [
        \ l:modifiers.' function '.a:definition.name.'('.join(l:arguments, ', ').')',
        \ '{',
    \ ]
endfunction

function s:prepareMethodModifiers(definition)
    if a:definition.isStatic
        return a:definition.visibility.' static'
    endif

    return a:definition.visibility
endfunction

function s:self.prepareMethodBody(definition, codeToExtract)
    return a:codeToExtract
endfunction

function s:self.makeInlineCodeToMethodBody(code)
    return 'return '.a:code.';'
endfunction

function s:self.makeReturnStatement(definition)
    if 0 < len(a:definition.returnVariables)
        let l:returnVariables = s:makeExpressionForReturningVariables(a:definition.returnVariables)

        return 'return '.l:returnVariables.';'
    else
        return ''
    endif
endfunction

function s:makeExpressionForReturningVariables(variableNames)
    let l:variables = s:makeVariableList(a:variableNames)

    if 1 == len(l:variables)
        return join(l:variables, '')
    else
        return 'array('.join(l:variables, ', ').')'
    endif
endfunction

function s:self.makeMethodFooterLines(definition)
    return ['}']
endfunction

function s:makeVariableList(names)
    let l:variables = []

    for l:name in a:names
        call add(l:variables, '$'.l:name)
    endfor

    return l:variables
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
