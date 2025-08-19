call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#adapters#phpactor#make()
    if 'spy' == get(g:, 'refactoring_toolbox_adapters_phpactor', '')
        return s:getCurrentSpyInstance()
    else
        return s:phpactor
    fi
endfunction

let s:phpactor = #{}

function s:phpactor.rpc(action, parameters)
    return phpactor#rpc(a:action, a:parameters)
endfunction

let s:spy_phpactor = #{}
let s:spy_phpactor_needs_init = v:true

function s:getCurrentSpyInstance()
    if s:spy_phpactor_needs_init
        let s:spy_phpactor = refactoring_toolbox#adapters#spy_phpactor#construct()

        let s:spy_phpactor_needs_init = v:false
    endif

    return s:spy_phpactor
endfunction

call refactoring_toolbox#adapters#vim#end_script()
