call refactoring_toolbox#adapters#vim#begin_script()

let s:SEARCH_NOT_FOUND = 0

function refactoring_toolbox#adapters#vim_texteditor#construct()
    let public = #{}
    let private = #{}

    function public.replaceStringWithTextBetweenLines(searchString, replaceWithText, startLine, endLine) closure
        let l:searchPattern = '\V'.escape(a:searchString, '\')
        let l:searchPattern = substitute(l:searchPattern, '\n', '\\n', 'g')

        call public.replacePatternWithTextBetweenLines(l:searchPattern, a:replaceWithText, a:startLine, a:endLine)
    endfunction

    function public.replacePatternWithTextBetweenLines(searchPattern, replaceWithText, startLine, endLine) closure
        let l:backupPosition = getcurpos()

        let l:searchPattern = escape(a:searchPattern, '/')

        let l:replaceWithText = escape(a:replaceWithText, '&/\')

        execute a:startLine . ',' . a:endLine . ':s/' . l:searchPattern . '/'. l:replaceWithText .'/ge'

        call setpos('.', l:backupPosition)
    endfunction

    function public.patternMatchesBetweenLines(pattern, startLine, endLine) closure
        return search('\%>' . a:startLine . 'l\%<' . a:endLine . 'l' . a:pattern, 'n') != s:SEARCH_NOT_FOUND
    endfunction

    function public.getWordOnCursor() closure
        return expand('<cword>')
    endfunction

    return public
endfunction

call refactoring_toolbox#adapters#vim#end_script()
