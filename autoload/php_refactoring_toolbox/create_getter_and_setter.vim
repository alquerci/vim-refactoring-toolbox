let s:php_regex_func_line = php_refactoring_toolbox#regex#func_line
let s:php_regex_const_line = php_refactoring_toolbox#regex#const_line
let s:php_regex_member_line = php_refactoring_toolbox#regex#member_line
let s:php_doc_var_type = php_refactoring_toolbox#regex#doc_var_type
let s:php_regex_class_line  = php_refactoring_toolbox#regex#class_line
let s:NULL = 'NONE'

function! php_refactoring_toolbox#create_getter_and_setter#execute()
    for l:property in s:parseProperties()
        try
            call s:createGetterAndSetterForProperty(l:property)
        catch "skip property"
            continue
        endtry
    endfor
endfunction

function! php_refactoring_toolbox#create_getter_and_setter#createOnlyGetters()
    for l:property in s:parseProperties()
        try
            call s:createGetterForProperty(l:property)
        catch "skip property"
            continue
        endtry
    endfor
endfunction

function! s:parseProperties()
    call s:moveToBeginOfFile()

    let l:properties = []

    while s:searchNextProperty() > 0
        call add(l:properties, s:parsePropertyOnCurrentPosition())
    endwhile

    return l:properties
endfunction

function! s:createGetterForProperty(property)
    let l:camelCaseName = s:convertNameToCamelCase(a:property.name)

    call s:validateGetter(l:camelCaseName)

    call s:declareGetterForProperty(l:camelCaseName, a:property.name, a:property.type)
endfunction

function! s:createGetterAndSetterForProperty(property)
    let l:camelCaseName = s:convertNameToCamelCase(a:property.name)

    call s:validateGetterAndSetter(l:camelCaseName)

    call s:declareSetterForProperty(l:camelCaseName, a:property.name, a:property.type)

    call s:declareGetterForProperty(l:camelCaseName, a:property.name, a:property.type)
endfunction

function! s:moveToBeginOfFile()
    normal! gg
endfunction

function! s:searchNextProperty()
    return search(s:php_regex_member_line, 'eW')
endfunction

function! s:parsePropertyOnCurrentPosition()
    let l:property = #{name: s:NULL, type: s:NULL}

    let l:property.name = s:parsePropertyNameOnCursorPosition()
    let l:property.type = s:findProopertyTypeOnCurrentPosition()

    return l:property
endfunction

function! s:parsePropertyNameOnCursorPosition()
    normal! w"xye

    return @x
endfunction

function! s:declarationHavePHPDoc()
    return '/' == trim(getline(line('.') - 1))[-1:]
endfunction

function! s:findProopertyTypeOnCurrentPosition()
    if s:declarationHavePHPDoc()
        return s:convertPHPDocTypeToHint(s:parseDocVarType())
    endif

    return s:NULL
endfunction

function! s:convertPHPDocTypeToHint(doctype)
    if '|null' == a:doctype[-5:]
        return '?'.a:doctype[0:-6]
    endif

    return a:doctype
endfunction

fun s:parseDocVarType()
    let l:cursorPosition = getcurpos()

    call s:backwardOneLine()
    call s:backwardOneLine()

    call search(s:php_doc_var_type, 'be', line('.'))

    " move on first char of the doctype
    normal! f@f lme

    " move on next space or newline
    call search('\s', 'e')

    " copy the doctype on @x
    normal! "xy`e
    let l:doctype = @x

    call setpos('.', l:cursorPosition)

    return l:doctype
endf

function! s:convertNameToCamelCase(name)
    return substitute(a:name, '^_\?\(.\)', '\U\1', '')
endfunction

function! s:validateGetterAndSetter(camelCaseName)
    if g:vim_php_refactoring_auto_validate_sg == 0
        call s:askWhetherToAddGetterAndSetterForProperty(a:camelCaseName)
    endif
endfunction

function! s:validateGetter(camelCaseName)
    if g:vim_php_refactoring_auto_validate_sg == 0
        call s:askWhetherToAddGetterForProperty(a:camelCaseName)
    endif
endfunction

function! s:askWhetherToAddGetterAndSetterForProperty(camelCaseName)
    call s:askWithMessage('Create set' . a:camelCaseName . '() and get' . a:camelCaseName . '()')
endfunction

function! s:askWhetherToAddGetterForProperty(camelCaseName)
    call s:askWithMessage('Create get' . a:camelCaseName . '()')
endfunction

function! s:askWithMessage(message)
    call s:echoError(a:message)

    if inputlist(["0. No", "1. Yes"]) == 0
        throw "skip property"
    endif
endfunction

function! s:declareSetterForProperty(camelCaseName, name, type)
    if search(s:php_regex_func_line . "set" . a:camelCaseName . '\>', 'n') == 0
        let l:argument = '$' . substitute(a:name, '^_', '', '')

        if s:NULL != a:type
            let l:argument = a:type . ' ' . l:argument
        endif

        call s:moveEndOfClass()

        if g:vim_php_refactoring_make_setter_fluent > 0
            call s:insertMethodWithSelfReturnHint("public", "set" . a:camelCaseName, [ l:argument ], "$this->" . a:name . " = $" . substitute(a:name, '^_', '', '') . ";")
        else
            call s:insertMethod("public", "set" . a:camelCaseName, [l:argument], "$this->" . a:name . " = $" . substitute(a:name, '^_', '', '') . ";")
        endif
    endif
endfunction

function! s:declareGetterForProperty(camelCaseName, name, type)
    if search(s:php_regex_func_line . "get" . a:camelCaseName . '\>', 'n') == 0
        let l:returnHint = ''

        if s:NULL != a:type
            let l:returnHint = ': ' . a:type
        endif

        call s:moveEndOfClass()

        call s:insertMethod("public", "get" . a:camelCaseName, [], "return $this->" . a:name . ";", l:returnHint)
    endif
endfunction

function! s:insertMethodWithSelfReturnHint(modifiers, name, params, impl)
    let l:indent = s:detectIntentation()

    call s:writeLine('')
    call s:writeLine(l:indent . a:modifiers . " function " . a:name . "(" . join(a:params, ", ") . "): self")
    call s:writeLine(l:indent . '{')
    call s:writeLine(l:indent . l:indent . a:impl)
    call s:insertFluentReturn(l:indent.l:indent)
    call s:writeLine(l:indent . '}')
endfunction

function! s:insertMethod(modifiers, name, params, impl, returnHint = '')
    let l:indent = s:detectIntentation()

    call s:writeLine('')
    call s:writeLine(l:indent . a:modifiers . " function " . a:name . "(" . join(a:params, ", ") . ")". a:returnHint)
    call s:writeLine(l:indent . '{')
    call s:writeLine(l:indent . l:indent . a:impl)
    call s:writeLine(l:indent . '}')
endfunction

function! s:insertFluentReturn(indent)
    if g:vim_php_refactoring_make_setter_fluent == 1
        call s:writeLine('')
        call s:writeLine(a:indent . 'return $this;')
    elseif g:vim_php_refactoring_make_setter_fluent == 2
        call s:echoError('Make fluent?')
        if inputlist(["0. No", "1. Yes"]) == 1
            call s:writeLine('')
            call s:writeLine(a:indent.'return $this;')
        endif
    else
        echoerr 'Invalid option for g:vim_php_refactoring_make_setter_fluent'
    endif
endfunction

function! s:detectIntentation()
    let l:line = getline(s:searchLineOfPreviousClassDeclaration())

    return substitute(l:line, '\S.*', '', '')
endfunction

function! s:searchLineOfPreviousClassDeclaration()
    let l:declarationPattern = '\%(' . join([s:php_regex_member_line, s:php_regex_const_line, s:php_regex_func_line], '\)\|\(') .'\)'

    return search(l:declarationPattern, 'bn')
endfunction

function! s:echoError(message)
    echohl ErrorMsg
    echomsg a:message
    echohl NONE
endfunction

function! s:moveEndOfClass()
    call search(s:php_regex_class_line, 'beW')
    call search('{', 'W')
    call searchpair('{', '', '}', 'W')

    call s:backwardOneLine()
endfunction

function! s:writeLine(text)
    call append(line('.'), a:text)

    call s:forwardOneLine()
endfunction

function! s:forwardOneLine()
    call cursor(line('.') + 1, 0)
endfunction

function! s:backwardOneLine()
    call cursor(line('.') - 1, 0)
endfunction
