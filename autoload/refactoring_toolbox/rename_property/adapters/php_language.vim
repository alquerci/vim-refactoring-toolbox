call refactoring_toolbox#adapters#vim#begin_script()

let s:regex_class_line = refactoring_toolbox#adapters#regex#class_line
let s:regex_after_word_boundary = refactoring_toolbox#adapters#regex#after_word_boundary
let s:regex_case_sensitive = refactoring_toolbox#adapters#regex#case_sensitive
let s:regex_property_declaration_or_usage = refactoring_toolbox#adapters#regex#member_declaration_or_usage
let s:regex_lookbehind_positive = refactoring_toolbox#adapters#regex#lookbehind_positive

function refactoring_toolbox#rename_property#adapters#php_language#construct()
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

    function public.makePropertyPattern(propertyName) closure
        let l:is_prefixed_with_property_marker = s:regex_case_sensitive.s:regex_property_declaration_or_usage.s:regex_lookbehind_positive

        return l:is_prefixed_with_property_marker.a:propertyName.s:regex_after_word_boundary
    endfunction

    function public.parseVariable(word) closure
        return substitute(a:word, '^\$*', '', '')
    endfunction

    return public
endfunction

call refactoring_toolbox#adapters#vim#end_script()
