call refactoring_toolbox#adaptor#vim#begin_script()

let s:index_line = 1
let s:index_column = 2

function refactoring_toolbox#extract_method#adaptor#vim_position#make()
    return s:self
endfunction

let s:self = #{
    \ positionHistory: [],
\ }

function s:self.moveToLineAndColumnFromPosition(line, column, position)
    let l:position = s:self.makePositionBasedOnPositionWithLineAndColumn(a:position, a:line, a:column)

    call s:self.moveToPosition(l:position)
endfunction

function s:self.makePositionBasedOnPositionWithLineAndColumn(position, line, column)
    let l:newPosition = a:position[:]

    let l:newPosition[s:index_line] = a:line
    let l:newPosition[s:index_column] = a:column

    return l:newPosition
endfunction

function s:self.getLineOfPosition(position)
    return a:position[s:index_line]
endfunction

function s:self.getColumnOfPosition(position)
    return a:position[s:index_column]
endfunction

function s:self.getCurrentPosition()
    return getcurpos()
endfunction

function s:self.backToPreviousPosition()
    call setpos('.', s:self.positionHistory[-1])

    let s:self.positionHistory = s:self.positionHistory[:-2]
endfunction

function s:self.getCurrentLine()
    return line('.')
endfunction

function s:self.getStartPositionOfSelection()
    call s:moveToStartOfSelection()

    let l:startPosition = s:self.getCurrentPosition()

    call s:self.backToPreviousPosition()

    return l:startPosition
endfunction

function s:self.getEndPositionOfSelection()
    call s:moveToEndOfSelection()

    let l:endPosition = s:self.getCurrentPosition()

    call s:self.backToPreviousPosition()

    return l:endPosition
endfunction

function s:self.moveToPosition(position)
    call s:addCurrentPositionToHistory()

    call setpos('.', a:position)
endfunction

function s:moveToStartOfSelection()
    call s:addCurrentPositionToHistory()

    normal! `<
endfunction

function s:moveToEndOfSelection()
    call s:addCurrentPositionToHistory()

    normal! `>
endfunction

function s:addCurrentPositionToHistory()
    call add(s:self.positionHistory, s:self.getCurrentPosition())
endfunction

function s:self.positionIsAfterPosition(position, referencePosition)
    if a:referencePosition[s:index_line] == a:position[s:index_line]
        return a:referencePosition[s:index_column] < a:position[s:index_column]
    endif

    return a:referencePosition[s:index_line] < a:position[s:index_line]
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
