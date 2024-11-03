call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#new_class#adapters#ts_language#make()
    return s:self
endfunction

let s:self = #{}

function s:self.getFileExtension()
    return 'ts'
endfunction

function s:self.makeClassFileLines(className)
    return [
        \ 'export class '.a:className.' {',
        \ '}',
    \ ]
endfunction

call refactoring_toolbox#adapters#vim#end_script()
