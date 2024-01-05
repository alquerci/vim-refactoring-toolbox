let s:regex_keyword = refactoring_toolbox#adaptor#js_regex#reserved_variable
let s:regex_mutation_symbols = refactoring_toolbox#adaptor#js_regex#mutation_symbols
let s:regex_var_name = refactoring_toolbox#adaptor#js_regex#var_name
let s:regex_func_line = refactoring_toolbox#adaptor#js_regex#func_line

call refactoring_toolbox#adaptor#vim#begin_script()

let s:NO_MATCH = -1

function refactoring_toolbox#extract_method#adaptor#js_language#make(position)
    let s:position = a:position
    let s:js_language_common = refactoring_toolbox#extract_method#adaptor#js_language_common#make(s:position)

    return s:self
endfunction

let s:self = #{}

function s:self.positionIsInStaticMethod(position)
    return v:false
endfunction

function s:self.getTopPositionOfMethodWithPosition(position)
    return s:js_language_common.searchPositionBackwardWithPatternFromPosition(s:regex_func_line, a:position)
endfunction

function s:self.getTopLineOfMethodWithPosition(position)
    let l:topPosition = s:self.getTopPositionOfMethodWithPosition(a:position)

    return s:position.getLineOfPosition(l:topPosition)
endfunction

function s:self.getBottomLineOfMethodWithPosition(position)
    let l:bottomPosition = s:js_language_common.getBottomPositionOfMethodWithPosition(s:self, a:position)

    return s:position.getLineOfPosition(l:bottomPosition)
endfunction

function s:self.moveEndOfFunction()
    let l:position = s:position.getCurrentPosition()

    let l:bottomPosition = s:js_language_common.getBottomPositionOfMethodWithPosition(s:self, l:position)

    call s:position.moveToPosition(l:bottomPosition)
endfunction

function s:self.getLocalVariablePattern()
    return s:regex_var_name
endfunction

function s:self.getMutatedLocalVariablePattern()
    return '\%('.s:regex_var_name.'\)\([ \n\t]*'.s:regex_mutation_symbols.'[ \t\n]\)\@='
endfunction

function s:self.variableExistsOnCode(variable, code)
    let l:pattern = s:js_language_common.makePatternForVariableName(a:variable)

    return match(a:code, l:pattern) != s:NO_MATCH
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

function s:self.makeMethodCallStatement(definition, codeToExtract)
    let l:assignment = s:makeAssignment(a:definition)
    let l:arguments = s:makeArguments(a:definition)

    if s:self.codeHasReturn(a:codeToExtract)
        let l:assignment = 'return '
    endif

    let l:callContext = s:makeMethodCallContext(a:definition)

    return l:assignment.l:callContext.a:definition.name.'('.l:arguments.')'
endfunction

function s:makeMethodCallContext(definition)
    if s:isAnObjectMethod(a:definition)
        let l:modifier = s:makeClassModifierForVisibility(a:definition.visibility)

        return 'this.'.l:modifier
    else
        return ''
    endif
endfunction

function s:self.makeMethodHeaderLines(definition)
    if s:isAnObjectMethod(a:definition)
        return s:makeObjectMethodHeaderLines(a:definition)
    else
        return s:makeFunctionMethodHeaderLines(a:definition)
    endif
endfunction

function s:isAnObjectMethod(definition)
    return 0 < a:definition.indentationLevel
endfunction

function s:makeObjectMethodHeaderLines(definition)
    let l:modifier = s:makeClassModifierForVisibility(a:definition.visibility)
    let l:arguments = s:makeArguments(a:definition)

    return [
        \ l:modifier.a:definition.name.'('.l:arguments.') {',
    \ ]
endfunction

function s:makeClassModifierForVisibility(visibility)
    if a:visibility == 'private'
        return '_'
    else
        return ''
    endif
endfunction

function s:makeFunctionMethodHeaderLines(definition)
    let l:arguments = s:makeArguments(a:definition)

    return [
        \ 'const '.a:definition.name.' = ('.l:arguments.') => {',
    \ ]
endfunction

function s:self.makeReturnStatement(definition)
    if 0 < len(a:definition.returnVariables)
        return 'return '.s:makeReturnVariables(a:definition)
    else
        return ''
    endif
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

call refactoring_toolbox#adaptor#vim#end_script()
