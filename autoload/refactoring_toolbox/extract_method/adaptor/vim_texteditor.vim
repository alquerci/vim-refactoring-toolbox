call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#extract_method#adaptor#vim_texteditor#make()
    return s:self
endfunction

let s:self = #{}

function s:self.deleteSelectedText()
    normal! gvs
endfunction

function s:self.isInVisualBlockMode()
    return visualmode() == ''
endfunction

function s:self.getStartPositionOfSelection()
    normal! `<

    return getcurpos()
endfunction

function s:self.getEndPositionOfSelection()
    normal! `>

    return getcurpos()
endfunction

function s:self.copyLinesBetweenCursorPositions(start, end)
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

call refactoring_toolbox#adaptor#vim#end_script()
