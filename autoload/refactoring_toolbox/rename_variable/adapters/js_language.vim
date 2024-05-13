let s:regex_func_line = refactoring_toolbox#adapters#js_regex#func_line
let s:regex_after_word_boundary = refactoring_toolbox#adapters#regex#after_word_boundary
let s:regex_before_word_boundary = refactoring_toolbox#adapters#regex#before_word_boundary
let s:regex_case_sensitive = refactoring_toolbox#adapters#regex#case_sensitive

call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#rename_variable#adapters#js_language#make()
    let s:js_language_common = refactoring_toolbox#rename_variable#adapters#js_language_common#make()

    return s:self
endfunction

let s:self = #{}

function s:self.parseVariable(word)
    return s:js_language_common.parseVariable(a:word)
endfunction

function s:self.formatVariable(name)
    return s:js_language_common.formatVariable(a:name)
endfunction

function s:self.makeVariablePattern(name)
    return s:js_language_common.makeVariablePattern(a:name)
endfunction

function s:self.makeVariableDefinitionPattern(name)
    return s:js_language_common.makeVariableDefinitionPattern(a:name)
endfunction

function s:self.findCurrentFunctionLineRange()
    return s:js_language_common.findCurrentFunctionLineRangeWithPattern(s:regex_func_line)
endfunction

function s:self.findParentScopeLineRange()
    return s:js_language_common.findParentScopeLineRangeWithPattern(s:regex_func_line)
endfunction

function s:self.findCurrentFunctionDefinitionLineRange()
    return s:js_language_common.findCurrentFunctionDefinitionLineRangeWithPattern(s:regex_func_line)
endfunction

call refactoring_toolbox#adapters#vim#end_script()
