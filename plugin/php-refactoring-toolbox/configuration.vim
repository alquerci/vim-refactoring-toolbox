try
    call php_refactoring_toolbox#vim#begin_plugin('php_refactoring_toolbox_configuration')
catch /plugin_loaded/
    finish
endtry

function s:main()
    call s:configure()
endfunction

function s:configure()
    if !exists('g:vim_php_refactoring_usage_logdir')
        let g:vim_php_refactoring_usage_logdir = getenv('HOME').'/.vim/log/vim-php-refactoring-toolbox'
    endif

    if !exists('g:vim_php_refactoring_auto_validate')
        let g:vim_php_refactoring_auto_validate = 0
    endif

    if !exists('g:vim_php_refactoring_auto_validate_sg')
        let g:vim_php_refactoring_auto_validate_sg = g:vim_php_refactoring_auto_validate
    endif

    if !exists('g:vim_php_refactoring_auto_validate_g')
        let g:vim_php_refactoring_auto_validate_g = g:vim_php_refactoring_auto_validate
    endif

    if !exists('g:vim_php_refactoring_auto_validate_rename')
        let g:vim_php_refactoring_auto_validate_rename = g:vim_php_refactoring_auto_validate
    endif

    if !exists('g:vim_php_refactoring_auto_validate_visibility')
        let g:vim_php_refactoring_auto_validate_visibility = g:vim_php_refactoring_auto_validate
    endif

    if !exists('g:vim_php_refactoring_default_method_visibility')
        let g:vim_php_refactoring_default_method_visibility = 'private'
    endif

    if !exists('g:vim_php_refactoring_make_setter_fluent')
        let g:vim_php_refactoring_make_setter_fluent = 0
    endif
endfunction

call s:main()

call php_refactoring_toolbox#vim#end_plugin()
