call refactoring_toolbox#adaptor#vim#begin_script()

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

    let l:newPosition[1] = a:line
    let l:newPosition[2] = a:column

    return l:newPosition
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

call refactoring_toolbox#adaptor#vim#end_script()
