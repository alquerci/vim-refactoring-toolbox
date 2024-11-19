call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#extract_variable#adapters#vim_language#make()
    return s:self
endfunction

let s:self = #{}

function s:self.makeVariableUsage(name)
    return 'l:'.a:name
endfunction

function s:self.makeAssignation(name, value)
    return 'let l:'.a:name.' = '.a:value
endfunction

call refactoring_toolbox#adapters#vim#end_script()
