call refactoring_toolbox#adapters#vim#begin_script()

let s:regex_class_line = refactoring_toolbox#adapters#regex#class_line
let s:regex_after_word_boundary = refactoring_toolbox#adapters#regex#after_word_boundary
let s:regex_case_sensitive = refactoring_toolbox#adapters#regex#case_sensitive
let s:regex_constant_declaration_or_usage = refactoring_toolbox#adapters#regex#constant_declaration_or_usage
let s:regex_lookbehind_positive = refactoring_toolbox#adapters#regex#lookbehind_positive

function refactoring_toolbox#rename_constant#adapters#php_language#construct()
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

    function public.makeConstantPattern(constantName) closure
        let l:is_prefixed_with_constant_marker = s:regex_case_sensitive.s:regex_constant_declaration_or_usage.s:regex_lookbehind_positive

        return l:is_prefixed_with_constant_marker.a:constantName.s:regex_after_word_boundary
    endfunction

    function public.parseConstant(word) closure
        return a:word
    endfunction

    function public.formatConstant(name) closure
        return toupper(a:name)
    endfunction

    return public
endfunction

call refactoring_toolbox#adapters#vim#end_script()
