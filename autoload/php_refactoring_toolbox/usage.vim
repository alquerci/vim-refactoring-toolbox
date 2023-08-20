call php_refactoring_toolbox#vim#begin_script()

function php_refactoring_toolbox#usage#increment(name)
    let l:directory = g:vim_php_refactoring_usage_logdir

    call mkdir(l:directory, 'p')

    call writefile([a:name], l:directory.'/usages.log', 'a')
endfunction

call php_refactoring_toolbox#vim#end_script()
