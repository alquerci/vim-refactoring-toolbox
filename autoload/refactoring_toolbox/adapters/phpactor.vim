call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#adapters#phpactor#make()
    if 'spy' == get(g:, 'refactoring_toolbox_adapters_phpactor', '')
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
    let s:spy_phpactor_last_parameters = a:parameters

    let s:spy_phpactor_rpc_total_calls += 1
endfunction

function s:spy_phpactor.getTotalCalls()
    return s:spy_phpactor_rpc_total_calls
endfunction

function s:spy_phpactor.resetTotalCalls()
    let s:spy_phpactor_last_parameters = v:null

    let s:spy_phpactor_rpc_total_calls = 0
endfunction

function s:spy_phpactor.getSourcePath()
    return s:spy_phpactor_last_parameters.source_path
endfunction

function s:spy_phpactor.getDestinationPath()
    return s:spy_phpactor_last_parameters.dest_path
endfunction

call refactoring_toolbox#adapters#vim#end_script()
