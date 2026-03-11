call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#extract_constant#adapters#vim_texteditor#make()
    let public = #{}
    let private = #{}
    let parent = refactoring_toolbox#adapters#vim_texteditor#construct()

    function public.isInVisualBlockMode() closure
        return visualmode() == ''
    endfunction

    function public.isInVisualLineMode() closure
        return visualmode() == 'V'
    endfunction

    function public.moveToLine(line) closure
        call cursor(a:line, 0)
    endfunction

    function public.appendText(text) closure
        call append(line('.'), '')
        call cursor(line('.') + 1, 0)

        call parent.insertText(a:text)
    endfunction

    function public.autoIndentLinesFromLine(totalLines, firstLine) closure
        let l:backupPosition = getcurpos()

        call cursor(a:firstLine, 0)

        execute 'normal ='.a:totalLines.'='

        call setpos('.', l:backupPosition)
    endfunction

    return extend(public, parent, 'keep')
endfunction

call refactoring_toolbox#adapters#vim#end_script()
