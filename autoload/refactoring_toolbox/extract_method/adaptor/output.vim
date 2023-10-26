call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#extract_method#adaptor#output#make()
    return s:self
endfunction

let s:self = #{}

function s:self.echoWarning(message)
    echohl WarningMsg
    echomsg a:message
    echohl NONE
endfunction

function s:self.echoError(message)
    echohl ErrorMsg
    echomsg a:message
    echohl NONE
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
