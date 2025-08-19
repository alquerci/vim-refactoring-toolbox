call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#rename_directory#directory_renamer#execute(
    \ input,
    \ output,
    \ phpactor,
    \ texteditor,
\ )
    try
        let s:phpactor = a:phpactor
        let s:input = a:input
        let s:output = a:output
        let s:texteditor = a:texteditor

        let [l:oldDirectory, l:newDirectory] = s:askForOldAndNewDirectory()

        call s:renameDirectoryWithNewName(l:oldDirectory, l:newDirectory)
    catch /user_cancel/
        call s:output.echoWarning('You cancelled rename directory.')
    endtry
endfunction

function s:askForOldAndNewDirectory()
    let l:oldDirectory = s:askQuestion("Old directory?", s:texteditor.getCurrentFileDirectory())
    let l:newDirectory = s:askQuestion("New directory?", l:oldDirectory)

    if l:oldDirectory == l:newDirectory
        throw 'user_cancel'
    endif

    if '' == l:newDirectory
        throw 'user_cancel'
    endif

    if '' == l:oldDirectory
        throw 'user_cancel'
    endif

    return [l:oldDirectory, l:newDirectory]
endfunction

function s:askQuestion(question, default = '')
    return s:input.askQuestionWithProposedAnswerAndDirectoryCompletion(a:question, a:default)
endfunction

function s:renameDirectoryWithNewName(oldDirectory, newDirectory)
    let l:files = s:searchPhpFilesInDirectory(a:oldDirectory)

    call s:renamePhpFilesFromOldDirectoryToNewDirectory(l:files, a:oldDirectory, a:newDirectory)
endfunction

function s:searchPhpFilesInDirectory(directory)
    return globpath(a:directory, "**/*.php", 1, 1)
endfunction

function s:renamePhpFilesFromOldDirectoryToNewDirectory(files, oldDirectory, newDirectory)
    for l:file in a:files
        let l:oldPath = l:file
        let l:newPath = substitute(l:file, a:oldDirectory, a:newDirectory, '')

        call s:movePhpFile(l:oldPath, l:newPath)
    endfor
endfunction

function s:movePhpFile(oldPath, newPath)
    call s:phpactor.rpc("move_class", {
        \ "source_path": a:oldPath,
        \ "dest_path": a:newPath,
        \ "confirmed": 'true'
    \ })
endfunction

call refactoring_toolbox#adapters#vim#end_script()
