call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#adapters#vim_texteditor#make()
    return s:self
endfunction

let s:self = #{}

function s:self.replacePatternWithTextBetweenLines(searchPattern, replaceWithText, startLine, endLine)
    let l:backupPosition = getcurpos()

    let l:searchPattern = escape(a:searchPattern, '/')
    let l:replaceWithText = escape(a:replaceWithText, '/')

    execute a:startLine . ',' . a:endLine . ':s/' . l:searchPattern . '/'. l:replaceWithText .'/ge'

    call setpos('.', l:backupPosition)
endfunction

function s:self.replaceStringWithTextBetweenLines(searchString, replaceWithText, startLine, endLine)
    let l:searchPattern = '\V'.escape(a:searchString, '\')

    call s:self.replacePatternWithTextBetweenLines(l:searchPattern, a:replaceWithText, a:startLine, a:endLine)
endfunction

call refactoring_toolbox#adapters#vim#end_script()
