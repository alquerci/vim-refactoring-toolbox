call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#usage#increment(name)
    let l:directory = g:refactoring_toolbox_usage_logdir

    call mkdir(l:directory, 'p')

    call writefile([a:name], l:directory.'/usages.log', 'a')
endfunction

call refactoring_toolbox#adapters#vim#end_script()
