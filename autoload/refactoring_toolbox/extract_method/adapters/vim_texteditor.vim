call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#extract_method#adapters#vim_texteditor#construct(position)
    let public = #{}
    let private = #{
        \ position: a:position,
        \ parent: refactoring_toolbox#adapters#vim_texteditor#construct(),
    \ }

    function public.deleteSelectedText() closure
        normal! gvs
    endfunction

    function public.isInVisualBlockMode() closure
        return visualmode() == ''
    endfunction

    function public.isInVisualMode() closure
        return visualmode() == 'v'
    endfunction

    function public.getStartPositionOfSelection() closure
        return private.position.getStartPositionOfSelection()
    endfunction

    function public.getEndPositionOfSelection() closure
        return private.position.getEndPositionOfSelection()
    endfunction

    function public.getLinesBetweenLineAndPosition(line, position) closure
        let l:start = private.position.makePositionBasedOnPositionWithLineAndColumn(
            \ a:position,
            \ a:line,
            \ 1,
        \ )

        return public.getLinesBetweenCursorPositions(l:start, a:position)
    endfunction

    function public.getLinesBetweenPositionAndLine(position, line) closure
        let l:end = private.position.makePositionBasedOnPositionWithLineAndColumn(
            \ a:position,
            \ a:line,
            \ len(getline(a:line)),
        \ )

        return public.getLinesBetweenCursorPositions(a:position, l:end)
    endfunction


    function public.getLinesBetweenCursorPositions(start, end) closure
        let l:startLine = private.position.getLineOfPosition(a:start)
        let l:endLine = private.position.getLineOfPosition(a:end)

        let l:selectionLines = getline(l:startLine, l:endLine)

        let l:startColumn = private.position.getColumnOfPosition(a:start)
        let l:endColumn = private.position.getColumnOfPosition(a:end)

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

    function public.moveToPosition(position) closure
        call private.position.moveToPosition(a:position)
    endfunction

    function public.backToPreviousPosition() closure
        call private.position.backToPreviousPosition()
    endfunction

    function public.getIndentForLevel(level) closure
        if 0 == a:level
            return ''
        endif

        let l:baseIndent = private.detectIntentation()

        return repeat(l:baseIndent, a:level)
    endfunction

    function private.detectIntentation() closure
        if &expandtab
            return repeat(' ', shiftwidth())
        else
            return "\t"
        fi
    endfunction

    function public.writeLine(text) closure
        call append(private.position.getCurrentLine(), a:text)

        call private.forwardOneLine()
    endfunction

    function private.forwardOneLine() closure
        call private.moveToLine(private.position.getCurrentLine() + 1)
    endfunction

    function private.moveToLine(line) closure
        call cursor(a:line, 0)
    endfunction

    function public.writeText(text) closure
        call private.parent.writeText(a:text)
    endfunction

    function public.getIndentationLevelOfLine(line) closure
        let l:lineIndentation = private.getLineIndentation(a:line)

        return private.determineIndentationLevelForIndentation(l:lineIndentation)
    endfunction

    function private.determineIndentationLevelForIndentation(indentation) closure
        return float2nr(ceil(len(a:indentation) / len(private.detectIntentation())))
    endfunction

    function private.getLineIndentation(line) closure
        let l:text = getline(a:line)

        return private.getBaseIndentOfText(l:text)
    endfunction

    function private.getBaseIndentOfText(text) closure
        return substitute(a:text, '\S.*', '', '')
    endfunction

    return public
endfunction

call refactoring_toolbox#adapters#vim#end_script()
