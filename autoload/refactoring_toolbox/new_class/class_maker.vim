call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#new_class#class_maker#execute(filesystem, texteditor, language)
    let s:filesystem = a:filesystem
    let s:texteditor = a:texteditor
    let s:language = a:language

    let l:newClassName = s:texteditor.getWordOnCursor()
    let l:newFilepath = s:getFilePathOfNewClassNamed(l:newClassName, s:language.getFileExtension())

    call s:filesystem.writeFileWithLines(l:newFilepath, s:language.makeClassFileLines(l:newClassName))

    call s:texteditor.openFileAside(l:newFilepath)
endfunction

function s:getFilePathOfNewClassNamed(className, extension)
    return s:texteditor.getCurrentFileDirectory().'/'.a:className.'.'.a:extension
endfunction

function refactoring_toolbox#new_class#class_maker#executeForPhp(phpactor, texteditor)
    let s:phpactor = a:phpactor
    let s:texteditor = a:texteditor

    let l:newClassName = s:texteditor.getWordOnCursor()
    let l:newFilepath = s:getFilePathOfNewClassNamed(l:newClassName, 'php')

    call s:makeClass(s:getCurrentFilePath(), l:newFilepath)
endfunction

function s:getCurrentFilePath()
    return s:texteditor.getCurrentFilePath()
endfunction

function s:makeClass(currentFilePath, newClassFilePath)
    call s:phpactor.rpc('class_new', {
        \ 'current_path': a:currentFilePath,
        \ 'new_path': a:newClassFilePath,
        \ 'variant': 'default',
    \ })
endfunction

call refactoring_toolbox#adapters#vim#end_script()