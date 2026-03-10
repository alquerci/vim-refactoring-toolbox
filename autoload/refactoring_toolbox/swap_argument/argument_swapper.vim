call refactoring_toolbox#adapters#vim#begin_script()

let s:SEPARATOR = ','
let s:DELIMITER_START = '('
let s:DELIMITER_END = ')'
let s:NOT_MATCHED = -1

function refactoring_toolbox#swap_argument#argument_swapper#construct(texteditor)
    let public = #{}
    let private = #{
        \ texteditor: a:texteditor,
    \ }

    function public.execute() closure
        let l:arguments = private.readArguments()
        let l:index = private.findArgumentIndex(l:arguments)

        call private.swapArgumentIndexForArguments(l:index, l:arguments)

        call private.writeArguments(l:arguments)
    endfunction

    function private.readArguments() closure
        let l:backupPosition = getcurpos()

        let l:arguments = []

        let l:start = searchpairpos(s:DELIMITER_START, '', s:DELIMITER_END, 'zcWb')
        let l:end = searchpairpos(s:DELIMITER_START, s:SEPARATOR, s:DELIMITER_END, 'zW')

        while 0 != l:end[1]
            let l:lines = private.getLinesBetweenLineColumnPairsExclude(l:start, l:end)
            call add(l:arguments, join(l:lines, ''))

            if private.lineColumnIsOnEndDelimiter(l:end[0], l:end[1])
                break
            endif

            let l:start = l:end
            let l:end = searchpairpos(s:DELIMITER_START, s:SEPARATOR, s:DELIMITER_END, 'zW')
        endwhile

        if "" == trim(l:arguments[-1], ' ')
            call remove(l:arguments, -1)
        endif

        call setpos('.', l:backupPosition)

        return l:arguments
    endfunction

    function private.lineColumnIsOnEndDelimiter(line, column) closure
        return s:DELIMITER_END == getline(a:line)[a:column - 1]
    endfunction

    function private.getLinesBetweenLineColumnPairsExclude(start, end) closure
        let l:start = copy(a:start)
        let l:end = copy(a:end)
        let l:start[1] = a:start[1] + 1
        let l:end[1] = a:end[1] - 1

        return private.getLinesBetweenLineColumnPairs(l:start, l:end)
    endfunction

    function private.getLinesBetweenLineColumnPairs(start, end) closure
        let l:startLine = a:start[0]
        let l:endLine = a:end[0]
        let l:startColumn = a:start[1]
        let l:endColumn = a:end[1]

        let l:selectionLines = getline(l:startLine, l:endLine)

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

    function private.findArgumentIndex(arguments) closure
        let l:selectedArgument = private.readArgumentOnCursor()

        let l:index = 0

        for l:argument in a:arguments
            if l:selectedArgument == l:argument
                return l:index
            endif

            let l:index += 1
        endfor

        return -1
    endfunction

    function private.readArgumentOnCursor() closure
        let l:start = searchpairpos(s:DELIMITER_START, s:SEPARATOR, s:DELIMITER_END, 'zncWb')
        let l:end = searchpairpos(s:DELIMITER_START, s:SEPARATOR, s:DELIMITER_END, 'zncW')

        let l:lines = private.getLinesBetweenLineColumnPairsExclude(l:start, l:end)

        return join(l:lines, '')
    endfunction

    function private.swapArgumentIndexForArguments(index, arguments) closure
        let l:target = private.determineTargetArgumentIndex(a:arguments, a:index)

        call private.swapListIndexFromSourceToTarget(a:arguments, a:index, l:target)
    endfunction

    function private.determineTargetArgumentIndex(arguments, index) closure
        if len(a:arguments) - 1 == a:index
            return 0
        else
            return a:index + 1
        endif
    endfunction

    function private.swapListIndexFromSourceToTarget(items, source, target) closure
        let l:argument = a:items[a:target]

        let a:items[a:target] = a:items[a:source]
        let a:items[a:source] = l:argument
    endfunction

    function private.writeArguments(arguments) closure
        let l:backupPosition = getcurpos()

        let l:arguments = map(a:arguments, {_, arg -> trim(arg, ' ')})
        let l:swap = join(l:arguments, s:SEPARATOR . ' ')

        execute 'normal di'.s:DELIMITER_START
        call private.texteditor.writeText(l:swap)

        call setpos('.', l:backupPosition)
    endfunction

    return public
endfunction

call refactoring_toolbox#adapters#vim#end_script()
