call refactoring_toolbox#adaptor#vim#begin_script()

let s:CURRENT_BUFFER = '%'

function refactoring_toolbox#inline_variable#variable_inliner#execute(language)
    let s:language = a:language

    let l:variable = s:readVariableOnCurrentPosition()
    let l:rightSideExpression = s:readAssignmentRightSideOnCurrentPosition()

    call s:removeExpressionOnCurrentPosition()

    call s:language.replaceNextOccurenceOfVariableWithValue(l:variable, l:rightSideExpression)
endfunction

function s:readVariableOnCurrentPosition()
    return s:language.readVariableOnCurrentPosition()
endfunction

function s:readAssignmentRightSideOnCurrentPosition()
    let l:endLine = s:language.findEndExpressionLineFromCurrentPosition()
    let l:lines = getline(s:getCurrentLine(), l:endLine)

    return s:language.parseAssignmentRightSideOfLines(l:lines)
endfunction

function s:removeExpressionOnCurrentPosition()
    let l:startLine = s:getCurrentLine()
    let l:endLine = s:language.findEndExpressionLineFromCurrentPosition()

    call deletebufline(s:CURRENT_BUFFER, l:startLine, l:endLine)
endfunction

function s:getCurrentLine()
    return line('.')
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
