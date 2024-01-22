call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#adaptor#vim_texteditor#make()
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

call refactoring_toolbox#adaptor#vim#end_script()
