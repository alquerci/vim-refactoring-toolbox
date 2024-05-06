try
    call refactoring_toolbox#adapters#vim#begin_plugin('refactoring_toolbox_configuration')
catch /plugin_loaded/
    finish
endtry

function s:main()
    call s:configure()
endfunction

function s:configure()
    if !exists('g:refactoring_toolbox_usage_logdir')
        let g:refactoring_toolbox_usage_logdir = getenv('HOME').'/.vim/log/refactoring-toolbox'
    endif

    if !exists('g:refactoring_toolbox_auto_validate')
        let g:refactoring_toolbox_auto_validate = 0
    endif

    if !exists('g:refactoring_toolbox_auto_validate_sg')
        let g:refactoring_toolbox_auto_validate_sg = g:refactoring_toolbox_auto_validate
    endif

    if !exists('g:refactoring_toolbox_auto_validate_g')
        let g:refactoring_toolbox_auto_validate_g = g:refactoring_toolbox_auto_validate
    endif

    if !exists('g:refactoring_toolbox_auto_validate_rename')
        let g:refactoring_toolbox_auto_validate_rename = g:refactoring_toolbox_auto_validate
    endif

    if !exists('g:refactoring_toolbox_auto_validate_visibility')
        let g:refactoring_toolbox_auto_validate_visibility = g:refactoring_toolbox_auto_validate
    endif

    if !exists('g:refactoring_toolbox_default_method_visibility')
        let g:refactoring_toolbox_default_method_visibility = 'private'
    endif

    if !exists('g:refactoring_toolbox_default_constant_visibility')
        let g:refactoring_toolbox_default_constant_visibility = 'public'
    endif

    if !exists('g:refactoring_toolbox_make_setter_fluent')
        let g:refactoring_toolbox_make_setter_fluent = 0
    endif
endfunction

call s:main()

call refactoring_toolbox#adapters#vim#end_plugin()
