call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#adapters#spy_phpactor#construct()
    let public = #{}
    let private = #{}

    function public.rpc(action, parameters) closure
        let private.lastRpcParameters = a:parameters

        let private.rpcTotalCalls += 1
    endfunction

    function public.resetTotalCalls() closure
        let private.lastRpcParameters = #{
            \ source_path: v:null,
            \ dest_path: v:null,
        \ }

        let private.rpcTotalCalls = 0
    endfunction

    function public.getTotalCalls() closure
        return private.rpcTotalCalls
    endfunction

    function public.getSourcePath() closure
        return private.lastRpcParameters.source_path
    endfunction

    function public.getDestinationPath() closure
        return private.lastRpcParameters.dest_path
    endfunction

    call public.resetTotalCalls()

    return public
endfunction

call refactoring_toolbox#adapters#vim#end_script()
