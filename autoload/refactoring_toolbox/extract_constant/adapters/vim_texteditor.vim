call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#extract_constant#adapters#vim_texteditor#make()
    let l:this = #{}

    call extend(l:this, refactoring_toolbox#adapters#vim_texteditor#make())
    call extend(l:this, s:self)

    return l:this
endfunction

let s:self = #{}

function s:self.isInVisualBlockMode()
    return visualmode() == ''
endfunction

function s:self.isInVisualLineMode()
    return visualmode() == 'V'
endfunction

function s:self.appendText(text)
    call append(line('.'), '')
    call cursor(line('.') + 1, 0)

    call s:writeText(a:text)
endfunction

function s:self.moveToLine(line)
    call cursor(a:line, 0)
endfunction

function s:writeText(text)
    if 1 == &l:paste
        let l:backuppaste = 'paste'
    else
        let l:backuppaste = 'nopaste'
    endif
    setlocal paste

    exec 'normal! i' . a:text

    exec 'setlocal '.l:backuppaste
endfunction

function s:self.autoIndentLinesFromLine(totalLines, firstLine)
    let l:backupPosition = getcurpos()

    call cursor(a:firstLine, 0)

    execute 'normal ='.a:totalLines.'='

    call setpos('.', l:backupPosition)
endfunction

call refactoring_toolbox#adapters#vim#end_script()
