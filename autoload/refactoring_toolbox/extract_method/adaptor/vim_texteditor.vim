call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#extract_method#adaptor#vim_texteditor#make()
    return s:self
endfunction

let s:self = #{
    \ positionHistory: [],
\ }

function s:self.deleteSelectedText()
    normal! gvs
endfunction

function s:self.isInVisualBlockMode()
    return visualmode() == ''
endfunction

function s:self.isInVisualMode()
    return visualmode() == 'v'
endfunction

function s:self.getStartPositionOfSelection()
    let l:backupPosition = s:getCurrentPosition()

    normal! `<

    let l:startPosition = s:getCurrentPosition()

    call s:self.moveToPosition(l:backupPosition)

    return l:startPosition
endfunction

function s:self.getEndPositionOfSelection()
    let l:backupPosition = s:getCurrentPosition()

    normal! `>

    let l:endPosition = s:getCurrentPosition()

    call s:self.moveToPosition(l:backupPosition)

    return l:endPosition
endfunction

function s:self.getLinesBetweenLineAndPosition(line, position)
    let l:start = s:makePositionbasedOnPositionWithLineAndColumn(
        \ a:position,
        \ a:line,
        \ 1,
    \ )

    return s:self.getLinesBetweenCursorPositions(l:start, a:position)
endfunction

function s:self.getLinesBetweenPositionAndLine(position, line)
    let l:end = s:makePositionbasedOnPositionWithLineAndColumn(
        \ a:position,
        \ a:line,
        \ len(getline(a:line)),
    \ )

    return s:self.getLinesBetweenCursorPositions(a:position, l:end)
endfunction

function s:makePositionbasedOnPositionWithLineAndColumn(position, line, column)
    let l:newPosition = a:position[:]

    let l:newPosition[1] = a:line
    let l:newPosition[2] = a:column

    return l:newPosition
endfunction

function s:self.getLinesBetweenCursorPositions(start, end)
    let l:selectionLines = getline(a:start[1], a:end[1])

    let l:startColumn = a:start[2]
    let l:endColumn = a:end[2]

    let l:totalLines = len(l:selectionLines)
    let l:lastLineIndex = l:totalLines - 1
    let l:lastLine = l:selectionLines[l:lastLineIndex]
    let l:lastLineLength = len(l:lastLine)

    let l:endColumnIndex = l:endColumn - l:lastLineLength - 1
    let l:selectionLines[l:lastLineIndex] = l:lastLine[: l:endColumnIndex]

    let l:startColumnIndex = l:startColumn - 1
    let l:selectionLines[0] = l:selectionLines[0][l:startColumnIndex :]

    return l:selectionLines
endfunction

function s:self.moveToPosition(position)
    call add(s:self.positionHistory, s:getCurrentPosition())

    call setpos('.', a:position)
endfunction

function s:getCurrentPosition()
    return getcurpos()
endfunction

function s:self.backToPreviousPosition()
    call setpos('.', s:self.positionHistory[-1])

    let s:self.positionHistory = s:self.positionHistory[:-2]
endfunction

function s:self.getIndentForLevel(level)
    if 0 == a:level
        return ''
    endif

    let l:baseIndent = s:detectIntentation()

    return repeat(l:baseIndent, a:level)
endfunction

function s:detectIntentation()
    if &expandtab
        return repeat(' ', shiftwidth())
    else
        return "\t"
    fi
endfunction

function s:self.writeLine(text)
    call append(s:getCurrentLine(), a:text)

    call s:forwardOneLine()
endfunction

function s:forwardOneLine()
    call s:moveToLine(s:getCurrentLine() + 1)
endfunction

function s:moveToLine(line)
    call cursor(a:line, 0)
endfunction

function s:getCurrentLine()
    return line('.')
endfunction

function s:self.writeText(text)
    if 1 == &l:paste
        let l:backuppaste = 'paste'
    else
        let l:backuppaste = 'nopaste'
    endif
    setlocal paste

    exec 'normal! i' . a:text

    exec 'setlocal '.l:backuppaste
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
