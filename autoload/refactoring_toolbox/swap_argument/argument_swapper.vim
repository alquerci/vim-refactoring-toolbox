call refactoring_toolbox#adapters#vim#begin_script()

let s:SEPARATOR = ', '
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
        let l:rawArguments = private.readRawArguments()

        return split(l:rawArguments, s:SEPARATOR)
    endfunction

    function private.readRawArguments() closure
        let l:line = getline('.')

        let l:startPosition = match(l:line, s:DELIMITER_START) + 1
        let l:endPosition = match(l:line, s:DELIMITER_END) - 1

        return l:line[l:startPosition : l:endPosition]
    endfunction

    function private.findArgumentIndex(arguments) closure
        let l:word = private.texteditor.getWordOnCursor()

        let l:index = 0

        for l:argument in a:arguments
            if private.argumentNameMatchArgumentCode(l:word, l:argument)
                return l:index
            endif

            let l:index += 1
        endfor

        return -1
    endfunction

    function private.argumentNameMatchArgumentCode(name, code) closure
        let l:equalPosition = match(a:code, '=')
        let l:namePattern = '$' . a:name . '\>'

        return s:NOT_MATCHED != match(a:code[: l:equalPosition], l:namePattern)
    endfunction

    function private.swapArgumentIndexForArguments(index, arguments) closure
        let l:target = private.determineTargetArgumentIndex(a:arguments, a:index)

        call private.swapListIndexFroSourceToTarget(a:arguments, a:index, l:target)
    endfunction

    function private.determineTargetArgumentIndex(arguments, index) closure
        if len(a:arguments) - 1 == a:index
            return 0
        else
            return a:index + 1
        endif
    endfunction

    function private.swapListIndexFroSourceToTarget(items, source, target) closure
        let l:argument = a:items[a:target]

        let a:items[a:target] = a:items[a:source]
        let a:items[a:source] = l:argument
    endfunction

    function private.writeArguments(arguments) closure
        let l:backupPosition = getcurpos()

        let l:swap = join(a:arguments, s:SEPARATOR)

        execute 'normal di'.s:DELIMITER_START
        call private.texteditor.writeText(l:swap)

        call setpos('.', l:backupPosition)
    endfunction

    return public
endfunction

call refactoring_toolbox#adapters#vim#end_script()
