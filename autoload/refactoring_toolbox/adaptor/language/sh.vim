call refactoring_toolbox#adaptor#vim#begin_script()

let s:regex_func_line = '^\w\+\s*()$'
let s:regex_var_name = '\w\+'
let s:regex_before_word_boudary = refactoring_toolbox#adaptor#regex#before_word_boudary
let s:regex_after_word_boudary = refactoring_toolbox#adaptor#regex#after_word_boudary
let s:NO_MATCH = -1

function refactoring_toolbox#adaptor#language#sh#make()
    return s:language
endfunction

let s:language = #{}

function s:language.currentLineIsInStaticMethod()
    return v:false
endfunction

function! s:language.moveEndOfFunction()
    call s:language.moveToCurrentFunctionDefinition()

    call s:moveToClosingBracket()
endfunction

function! s:moveToClosingBracket()
    call search('{', 'W')
    call searchpair('{', '', '}', 'W')
endfunction

function s:language.moveToCurrentFunctionDefinition()
    call search(s:regex_func_line, 'bW')
endfunction

function s:language.getLocalVariablePattern()
    return s:makeLocalVariablePatternForName(s:regex_var_name)
endfunction

function s:makeLocalVariablePatternForName(name)
    let l:mutatePattern = s:makeMutateVariablePatternForName(a:name)
    let l:braceVariable = s:makeUsageVariableForName(a:name)

    return '\%('.l:mutatePattern.'\|'.l:braceVariable.'\)'
endfunction

function s:makeUsageVariableForName(name)
    return '\%(\${\)\@<='.s:makeVariableNamePatternForName(a:name).'\(}\)\@='
endfunction

function s:language.getMutatedLocalVariablePattern()
    return s:makeMutateVariablePatternForName(s:regex_var_name)
endfunction

function s:makeMutateVariablePatternForName(name)
    return '\%('.s:makeVariableNamePatternForName(a:name).'\)\(=\)\@='
endfunction

function s:makeVariableNamePatternForName(name)
    return s:regex_before_word_boudary.a:name.s:regex_after_word_boudary
endfunction

function s:language.variableExistsOnCode(variable, code)
    let l:pattern = s:makeLocalVariablePatternForName(a:variable)

    return match(a:code, l:pattern) != s:NO_MATCH
endfunction

function s:language.codeHasReturn(code)
    let l:returnKeywordPattern = '^\_s*return\_s'
    let l:lines = split(a:code, "\n")

    return match(l:lines, l:returnKeywordPattern) != s:NO_MATCH
endfunction

function! s:language.makeMethodCallStatement(codeToExtract, definition)
    let l:methodCall = s:makeMethodCall(a:definition)

    if s:language.codeHasReturn(a:codeToExtract)
        return s:language.makeReturnCode(l:methodCall)
    else
        let l:assigment = s:makeAssigment(a:definition)

        return l:methodCall.l:assigment
    endif
endfunction

function! s:makeMethodCall(definition)
    let l:arguments = s:makeVariableList(a:definition.arguments)

    if 0 < len(l:arguments)
        let l:arguments = ' "'.join(l:arguments, '" "').'"'
    else
        let l:arguments = ''
    endif

    return a:definition.name.l:arguments
endfunction

function s:language.makeReturnCode(code)
    return 'return '.a:code
endfunction

function! s:makeAssigment(definition)
    let l:returnVariables = a:definition.returnVariables

    if len(l:returnVariables) == 0
        return ''
    elseif len(l:returnVariables) == 1
        return "\n".l:returnVariables[0].'=${'.a:definition.name.'__return}'
    else
        let l:code = "\n"
        let l:index = 0

        for l:variable in l:returnVariables
            let l:code = l:code.l:variable.'=${'.a:definition.name.'__return_'.l:index.'}'."\n"
            let l:index += 1
        endfor

        return substitute(l:code, '\n$', '', 'g')
    endif
endfunction

function s:language.makeInlineCodeToMethodBody(code)
    return a:code
endfunction

function s:language.prepareMethodBody(definition, codeToExtract)
    let l:methodBody = a:codeToExtract
    let l:argumentIndex = 0

    for l:variableName in a:definition.arguments
        let l:argumentIndex += 1

        let l:methodBody = substitute(l:methodBody, s:makeUsageVariableForName(l:variableName), l:argumentIndex, 'g')
    endfor

    return l:methodBody
endfunction

function s:language.makeReturnStatement(definition)
    let l:returnVariables = a:definition.returnVariables

    if len(l:returnVariables) == 1
        return a:definition.name.'__return=${'.l:returnVariables[0].'}'
    else
        let l:code = ''
        let l:index = 0

        for l:variable in l:returnVariables
            let l:code = l:code.a:definition.name.'__return_'.l:index.'=${'.l:variable.'}'."\n"
            let l:index += 1
        endfor

        return substitute(l:code, '\n$', '', 'g')
    endif
endfunction

function s:language.getMethodIndentationLevel()
    return 0
endfunction

function s:language.makeMethodFirstLine(definition)
    return a:definition.name.' ()'
endfunction

function s:makeVariableList(names)
    let l:variables = []

    for l:name in a:names
        call add(l:variables, '${'.l:name.'}')
    endfor

    return l:variables
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
