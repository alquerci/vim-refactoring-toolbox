call refactoring_toolbox#adapters#vim#begin_script()

let s:SEPARATOR = ','
let s:DELIMITER_START = '('
let s:DELIMITER_END = ')'

function refactoring_toolbox#multi_line#multiliner#construct()
    let public = #{}
    let private = #{
        \ lastDelimiterIsEnding: v:false,
    \ }

    function public.execute() closure
        call private.moveToFirstCharacter()
        call private.pressEnter()

        while private.cursorIsNotOnEndDelimiter()
            call private.moveToNextPosition()
            call private.pressEnter()
        endwhile
    endfunction

    function private.moveToFirstCharacter() closure
        let l:position = private.searchFirstPosition()

        call cursor(l:position[0], l:position[1])
    endfunction

    function private.searchFirstPosition() closure
        let l:position = searchpairpos(s:DELIMITER_START, '', s:DELIMITER_END, 'nzcWb')

        return [
            \ l:position[0],
            \ l:position[1] + 1,
        \ ]
    endfunction

    function private.cursorIsNotOnEndDelimiter() closure
        return !private.lastDelimiterIsEnding
    endfunction

    function private.moveToNextPosition() closure
        let l:position = private.searchNextPosition()

        call cursor(l:position[0], l:position[1])
    endfunction

    function private.searchNextPosition() closure
        let l:position = searchpairpos(s:DELIMITER_START, s:SEPARATOR, s:DELIMITER_END, 'nzcW')

        let private.lastDelimiterIsEnding = private.lineColumnIsOnEndDelimiter(l:position[0], l:position[1])

        if private.lastDelimiterIsEnding
            return l:position
        else
            return [l:position[0], l:position[1] + 1]
        endif
    endfunction

    function private.lineColumnIsOnEndDelimiter(line, column) closure
        return s:DELIMITER_END == getline(a:line)[a:column - 1]
    endfunction

    function private.pressEnter() closure
        execute 'normal i'."\n"
    endfunction

    return public
endfunction

call refactoring_toolbox#adapters#vim#end_script()
