call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#rename_variable#adaptor#output#make()
    return s:self
endfunction

let s:self = #{}

function s:self.echoWarning(message)
    echohl WarningMsg
    echomsg a:message
    echohl NONE
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
