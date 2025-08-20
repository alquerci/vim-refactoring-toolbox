call refactoring_toolbox#adapters#vim#begin_script()

let s:regex_class_line = refactoring_toolbox#adapters#regex#class_line

let s:regex_func_line = refactoring_toolbox#adapters#regex#func_line
let s:regex_after_word_boundary = refactoring_toolbox#adapters#regex#after_word_boundary
let s:regex_before_function = '\%(\%('.s:regex_func_line.'\)\|$this->\|self::\)\@<='

function refactoring_toolbox#rename_method#adapters#php_language#construct()
    let public = #{}
    let private = #{}

    function public.findCurrentClassLineRange() closure
        let l:backupPosition = getcurpos()

        call search(s:regex_class_line, 'beW')
        call search('{', 'W')
        let l:startLine = line('.')
        call searchpair('{', '', '}', 'W')
        let l:stopLine = line('.')

        call setpos('.', l:backupPosition)

        return [l:startLine, l:stopLine]
    endfunction

    function public.makeMethodPattern(methodName) closure
        return s:regex_before_function.a:methodName.s:regex_after_word_boundary
    endfunction

    function public.parseMethod(word) closure
        return a:word
    endfunction

    return public
endfunction

call refactoring_toolbox#adapters#vim#end_script()
