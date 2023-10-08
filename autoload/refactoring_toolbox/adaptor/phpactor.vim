call refactoring_toolbox#adaptor#vim#begin_script()

function refactoring_toolbox#adaptor#phpactor#make()
    if 'spy' == get(g:, 'refactoring_toolbox_adaptor_phpactor', '')
        return s:spy_phpactor
    else
        return s:phpactor
    fi
endfunction

let s:phpactor = #{}

function s:phpactor.rpc(action, parameters)
    return phpactor#rpc(a:action, a:parameters)
endfunction

let s:spy_phpactor = #{}
let s:spy_phpactor_rpc_total_calls = 0

function s:spy_phpactor.rpc(action, parameters)
    let s:spy_phpactor_rpc_total_calls += 1
endfunction

function s:spy_phpactor.getTotalCalls()
    return s:spy_phpactor_rpc_total_calls
endfunction

function s:spy_phpactor.resetTotalCalls()
    let s:spy_phpactor_rpc_total_calls = 0
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
