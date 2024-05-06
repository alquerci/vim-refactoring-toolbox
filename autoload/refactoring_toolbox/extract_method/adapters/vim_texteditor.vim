call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#extract_method#adapters#vim_texteditor#make(position)
    let s:position = a:position

    return s:self
endfunction

let s:self = #{}

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
    return s:position.getStartPositionOfSelection()
endfunction

function s:self.getEndPositionOfSelection()
    return s:position.getEndPositionOfSelection()
endfunction

function s:self.getLinesBetweenLineAndPosition(line, position)
    let l:start = s:position.makePositionBasedOnPositionWithLineAndColumn(
        \ a:position,
        \ a:line,
        \ 1,
    \ )

    return s:self.getLinesBetweenCursorPositions(l:start, a:position)
endfunction

function s:self.getLinesBetweenPositionAndLine(position, line)
    let l:end = s:position.makePositionBasedOnPositionWithLineAndColumn(
        \ a:position,
        \ a:line,
        \ len(getline(a:line)),
    \ )

    return s:self.getLinesBetweenCursorPositions(a:position, l:end)
endfunction


function s:self.getLinesBetweenCursorPositions(start, end)
    let l:startLine = s:position.getLineOfPosition(a:start)
    let l:endLine = s:position.getLineOfPosition(a:end)

    let l:selectionLines = getline(l:startLine, l:endLine)

    let l:startColumn = s:position.getColumnOfPosition(a:start)
    let l:endColumn = s:position.getColumnOfPosition(a:end)

    let l:totalLines = len(l:selectionLines)

    if 0 == l:totalLines
        return []
    endif

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
    call s:position.moveToPosition(a:position)
endfunction

function s:self.backToPreviousPosition()
    call s:position.backToPreviousPosition()
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
    call append(s:position.getCurrentLine(), a:text)

    call s:forwardOneLine()
endfunction

function s:forwardOneLine()
    call s:moveToLine(s:position.getCurrentLine() + 1)
endfunction

function s:moveToLine(line)
    call cursor(a:line, 0)
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

function s:self.getIndentationLevelOfLine(line)
    let l:lineIndentation = s:getLineIndentation(a:line)

    return s:determineIndentationLevelForIndentation(l:lineIndentation)
endfunction

function s:determineIndentationLevelForIndentation(indentation)
    return float2nr(ceil(len(a:indentation) / len(s:detectIntentation())))
endfunction

function s:getLineIndentation(line)
    let l:text = getline(a:line)

    return s:getBaseIndentOfText(l:text)
endfunction

function s:getBaseIndentOfText(text)
    return substitute(a:text, '\S.*', '', '')
endfunction

call refactoring_toolbox#adapters#vim#end_script()
