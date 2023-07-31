function! php_refactoring_toolbox#rename_directory#execute()
    let l:oldDirectory = s:askQuestion("Old directory?")
    let l:newDirectory = s:askQuestion("New directory?", l:oldDirectory)

    let l:files = s:searchPhpFilesInDirectory(l:oldDirectory)

    for l:file in l:files
        let l:oldPath = l:file
        let l:newPath = substitute(l:file, l:oldDirectory, l:newDirectory, '')

        call s:movePhpFile(l:oldPath, l:newPath)
    endfor
endfunction

function! s:searchPhpFilesInDirectory(directory)
    return globpath(a:directory, "**/*.php", 1, 1)
endfunction

function! s:movePhpFile(oldPath, newPath)
    call phpactor#rpc("move_class", { "source_path": a:oldPath, "dest_path": a:newPath, "confirmed": 'true' })
endfunction

function! s:askQuestion(question, default = '')
    let l:prompt = s:makeQuestionPrompt(a:question, a:default)

    return s:sendQuestionAndCollectAnswer(l:prompt, a:default)
endfunction

function! s:makeQuestionPrompt(question, default)
    return a:question.' '
endfunction

function! s:sendQuestionAndCollectAnswer(prompt, default)
    return input(a:prompt, a:default, "dir")
endfunction
