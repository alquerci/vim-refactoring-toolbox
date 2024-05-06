call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#adapters#output#make()
    return s:self
endfunction

let s:self = #{}

function s:self.echoWarning(message)
    echohl WarningMsg
    echomsg a:message
    echohl NONE
endfunction

call refactoring_toolbox#adapters#vim#end_script()
