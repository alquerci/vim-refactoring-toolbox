call refactoring_toolbox#adaptor#vim#begin_script()

let s:regex_class_line = refactoring_toolbox#adaptor#regex#class_line
let s:regex_func_line = refactoring_toolbox#adaptor#regex#func_line
let s:regex_after_word_boundary = refactoring_toolbox#adaptor#regex#after_word_boudary
let s:regex_case_sensitive = refactoring_toolbox#adaptor#regex#case_sensitive
let s:regex_local_var_prefix = refactoring_toolbox#adaptor#regex#local_var_prefix
let s:NO_MATCH = -1

function refactoring_toolbox#extract_property#php#execute(texteditor)
    let s:texteditor = a:texteditor

    let l:name = s:readNameOnCurrentPosition()

    call s:replaceVariableWithPropertyAccess(l:name)

    call s:addPropertyDeclaration(l:name)

    if s:variableExistsInArgument(l:name)
        call s:addAssignFromArgument(l:name)
    endif
endfunction

function s:readNameOnCurrentPosition()
    let l:word = expand('<cword>')

    return s:parseVariableNameFromWord(l:word)
endfunction

function s:parseVariableNameFromWord(word)
    return substitute(a:word, '^\$', '', '')
endfunction

function s:replaceVariableWithPropertyAccess(name)
    let l:variablePattern = s:makeVariablePattern(a:name)

    call s:replaceInCurrentFunction(l:variablePattern, '$this->'.a:name)
endfunction

function s:makeVariablePattern(variableName)
    return s:regex_case_sensitive.s:regex_local_var_prefix.a:variableName.s:regex_after_word_boundary
endfunction

function s:replaceInCurrentFunction(search, replace)
    let [l:startLine, l:stopLine] = s:findCurrentFunctionLineRange()

    call s:texteditor.replacePatternWithTextBetweenLines(a:search, a:replace, l:startLine, l:stopLine)
endfunction

function s:findCurrentFunctionLineRange()
    let l:backupPosition = getcurpos()

    call search(s:regex_func_line, 'beW')

    call s:moveToOpenBracket()
    let l:startLine = line('.')

    call s:moveToClosingBracket()
    let l:stopLine = line('.')

    call setpos('.', l:backupPosition)

    return [l:startLine, l:stopLine]
endfunction

function s:moveToClosingBracket()
    call searchpair('{', '', '}', 'W')
endfunction

function s:addPropertyDeclaration(name)
    let l:backupPosition = getcurpos()

    let l:indent = s:detectIntentation()

    call s:moveToLineToInsertNewProperty()
    call s:writeLine(l:indent.'private $'.a:name.';')
    call s:writeLine('')

    call setpos('.', l:backupPosition)
endfunction

function s:detectIntentation()
    if &expandtab
        return repeat(' ', shiftwidth())
    else
        return "\t"
    fi
endfunction

function s:moveToLineToInsertNewProperty()
    call search(s:regex_class_line, 'bcz')

    call s:moveToOpenBracket()
endfunction

function s:moveToOpenBracket()
    call search('{', 'W')
endfunction

function s:writeLine(text)
    call append(s:getCurrentLine(), a:text)

    call s:forwardOneLine()
endfunction

function s:getCurrentLine()
    return line('.')
endfunction

function s:forwardOneLine()
    call s:moveToLine(s:getCurrentLine() + 1)
endfunction

function s:moveToLine(line)
    call cursor(a:line, 0)
endfunction

function s:variableExistsInArgument(name)
    let [l:startLine, l:stopLine] = s:findCurrentFunctionDeclarationLineRange()

    let l:content = s:joinLinesBetween(l:startLine, l:stopLine)
    let l:pattern = s:makeVariablePattern(a:name)

    return match(l:content, l:pattern) != s:NO_MATCH
endfunction

function s:joinLinesBetween(topLine, bottomLine)
    return join(getline(a:topLine, a:bottomLine))
endfunction

function s:findCurrentFunctionDeclarationLineRange()
    let l:backupPosition = getcurpos()

    call search(s:regex_func_line, 'beW')
    let l:startLine = line('.')

    call s:moveToOpenBracket()
    let l:stopLine = line('.')

    call setpos('.', l:backupPosition)

    return [l:startLine, l:stopLine]
endfunction

function s:addAssignFromArgument(name)
    let l:backupPosition = getcurpos()

    let l:indent = s:detectIntentation()

    call s:moveToLineToInsertAssignFromArgument()

    call s:writeLine(l:indent.l:indent.'$this->'.a:name.' = $'.a:name.';')
    call s:writeLine('')

    call setpos('.', l:backupPosition)
endfunction

function s:moveToLineToInsertAssignFromArgument()
    call search(s:regex_func_line, 'bcz')

    call s:moveToOpenBracket()
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
