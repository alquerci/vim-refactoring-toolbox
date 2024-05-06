let s:texteditor = refactoring_toolbox#rename_directory#adapters#texteditor#make()

call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#rename_directory#directory_renamer#execute(
    \ input,
    \ phpactor,
\ )
    let s:phpactor = a:phpactor
    let s:input = a:input

    let l:oldDirectory = s:askQuestion("Old directory?", s:texteditor.getCurrentDirectory())
    let l:newDirectory = s:askQuestion("New directory?", l:oldDirectory)

    let l:files = s:searchPhpFilesInDirectory(l:oldDirectory)

    for l:file in l:files
        let l:oldPath = l:file
        let l:newPath = substitute(l:file, l:oldDirectory, l:newDirectory, '')

        call s:movePhpFile(l:oldPath, l:newPath)
    endfor
endfunction

function refactoring_toolbox#rename_directory#directory_renamer#setTextEditor(texteditor)
    let s:texteditor = a:texteditor
endfunction

function s:searchPhpFilesInDirectory(directory)
    return globpath(a:directory, "**/*.php", 1, 1)
endfunction

function s:movePhpFile(oldPath, newPath)
    call s:phpactor.rpc("move_class", {
        \ "source_path": a:oldPath,
        \ "dest_path": a:newPath,
        \ "confirmed": 'true'
    \ })
endfunction

function s:askQuestion(question, default = '')
    return s:input.askQuestionWithProposedAnswerAndDirectoryCompletion(a:question, a:default)
endfunction

call refactoring_toolbox#adapters#vim#end_script()
