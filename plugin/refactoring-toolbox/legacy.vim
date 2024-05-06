if exists('g:refactoring_toolbox_loaded')
    finish
endif
let g:refactoring_toolbox_loaded = 1

" Config {{{
" VIM function to call to document the current line
if !exists('g:refactoring_toolbox_phpdoc')
    let g:refactoring_toolbox_phpdoc = 'PhpDoc'
endif

if !exists('g:refactoring_toolbox_default_property_visibility')
    let g:refactoring_toolbox_default_property_visibility = 'private'
endif

if !exists('g:refactoring_toolbox_use_default_mapping')
    let g:refactoring_toolbox_use_default_mapping = 1
endif
" }}}

" Refactoring mapping {{{
if g:refactoring_toolbox_use_default_mapping == 1
    nnoremap <unique> <Leader>eu :call PhpExtractUse()<Enter>
    nnoremap <unique> <Leader>np :call PhpCreateProperty()<Enter>
    nnoremap <unique> <Leader>du :call PhpDetectUnusedUseStatements()<Enter>
    vnoremap <unique> <Leader>== :call PhpAlignAssigns()<Enter>
    nnoremap <unique> <Leader>da :call PhpDocAll()<Enter>
endif
" }}}

fun s:incrementUsage(name)
    call refactoring_toolbox#usage#increment(a:name)
endf

" +--------------------------------------------------------------+
" |   VIM REGEXP REMINDER   |    Vim Regex       |   Perl Regex   |
" |===============================================================|
" | Vim non catchable       | \%(.\)             | (?:.)          |
" | Vim negative lookahead  | Start\(Date\)\@!   | Start(?!Date)  |
" | Vim positive lookahead  | Start\(Date\)\@=   | Start(?=Date)  |
" | Vim negative lookbehind | \(Start\)\@<!Date  | (?<!Start)Date |
" | Vim positive lookbehind | \(Start\)\@<=Date  | (?<=Start)Date |
" | Multiline search        | \_s\_.             | \s\. multiline |
" +--------------------------------------------------------------+

" Regex defintion {{{
let s:php_regex_phptag_line = '<?\%(php\)\?'
let s:php_regex_ns_line     = '^namespace\_s\+[\\_A-Za-z0-9]*\_s*[;{]'
let s:php_regex_use_line    = '^use\_s\+[\\_A-Za-z0-9]\+\%(\_s\+as\_s\+[_A-Za-z0-9]\+\)\?\_s*\%(,\_s\+[\\_A-Za-z0-9]\+\%(\_s\+as\_s\+[_A-Za-z0-9]\+\)\?\_s*\)*;'
let s:php_regex_class_line  = refactoring_toolbox#adapters#regex#class_line
let s:php_regex_const_line = refactoring_toolbox#adapters#regex#const_line
let s:php_regex_member_line = refactoring_toolbox#adapters#regex#member_line
let s:php_regex_func_line = refactoring_toolbox#adapters#regex#func_line

let s:php_regex_assignment  = '+=\|-=\|*=\|/=\|=\~\|!=\|='
let s:php_regex_fqcn        = '[\\_A-Za-z0-9]*'
let s:php_regex_cn          = '[_A-Za-z0-9]\+'
" }}}

function! PhpDocAll() " {{{
    call s:incrementUsage('PhpDocAll')

    if exists("*" . g:refactoring_toolbox_phpdoc) == 0
        call s:PhpEchoError(g:refactoring_toolbox_phpdoc . '() vim function doesn''t exists.')
        return
    endif
    normal! magg
    while search(s:php_regex_class_line, 'eW') > 0
        call s:PhpDocument()
    endwhile
    normal! gg
    while search(s:php_regex_member_line, 'eW') > 0
        call s:PhpDocument()
    endwhile
    normal! gg
    while search(s:php_regex_func_line, 'eW') > 0
        call s:PhpDocument()
    endwhile
    normal! `a
endfunction
" }}}

function! s:PhpEchoError(message) " {{{
    echohl ErrorMsg
    echomsg a:message
    echohl NONE
endfunction
" }}}

function! PhpExtractUse() " {{{
    call s:incrementUsage('PhpExtractUse')

    normal! mr
    let l:fqcn = s:PhpGetFQCNUnderCursor()
    let l:use  = s:PhpGetDefaultUse(l:fqcn)
    let l:defaultUse = l:use
    if strlen(use) == 0
        let defaultUse = s:PhpGetShortClassName(l:fqcn)
    endif

    " Use negative lookahead and behind to make sure we don't replace exact string
    exec ':%s/\%([''"]\)\@<!' . substitute(l:fqcn, '[\\]', '\\\\', 'g') . '\%([''"]\)\@!/' . l:defaultUse . '/ge'
    if strlen(l:use)
        call s:PhpInsertUseStatement(l:fqcn . ' as ' . l:use)
    else
        call s:PhpInsertUseStatement(l:fqcn)
    endif
    normal! `r
endfunction
" }}}

function! PhpCreateProperty() " {{{
    call s:incrementUsage('PhpCreateProperty')

    let l:name = inputdialog("Name of new property: ")
    if g:refactoring_toolbox_auto_validate_visibility == 0
        let l:visibility = inputdialog("Visibility (default is " . g:refactoring_toolbox_default_property_visibility . "): ")
        if empty(l:visibility)
            let l:visibility =  g:refactoring_toolbox_default_property_visibility
        endif
    else
        let l:visibility =  g:refactoring_toolbox_default_property_visibility
    endif
    call s:PhpInsertProperty(l:name, l:visibility)
endfunction
" }}}

function! PhpDetectUnusedUseStatements() " {{{
    call s:incrementUsage('PhpDetectUnusedUseStatements')

    normal! mrgg
    while search('^use', 'W')
        let l:startLine = line('.')
        call search(';\_s*', 'eW')
        let l:endLine = line('.')
        let l:line = join(getline(l:startLine, l:endLine))
        for l:useStatement in split(substitute(l:line, '^\%(use\)\?\s*\([^;]*\);', '\1', ''), ',')
            let l:matches = matchlist(l:useStatement, '\s*\\\?\%([_A-Za-z0-9]\+\\\)*\([_A-Za-z0-9]\+\)\%(\s*as\s*\([_A-Za-z0-9]\+\)\)\?')
            let l:alias = s:PhpPopList(l:matches)
            if search(l:alias, 'nW') == 0
                echo 'Unused: ' . l:useStatement
            endif
        endfor
    endwhile
    normal! `r
endfunction
" }}}

function! PhpAlignAssigns() range " {{{
    call s:incrementUsage('PhpAlignAssigns')

" This funcion was took from :
" Vim refactoring plugin
" Maintainer: Eustaquio 'TaQ' Rangel
" License: GPL
" URL: git://github.com/taq/vim-refact.git
    let l:max   = 0
    let l:maxo  = 0
    let l:linc  = ""
    for l:line in range(a:firstline,a:lastline)
        let l:linc  = getbufline("%", l:line)[0]
        let l:rst   = match(l:linc, '\%(' . s:php_regex_assignment . '\)')
        if l:rst < 0
            continue
        endif
        let l:rstl  = matchstr(l:linc, '\%(' . s:php_regex_assignment . '\)')
        let l:max   = max([l:max, strlen(substitute(strpart(l:linc, 0, l:rst), '\s*$', '', '')) + 1])
        let l:maxo  = max([l:maxo, strlen(l:rstl)])
    endfor
    let l:formatter= '\=printf("%-'.l:max.'s%-'.l:maxo.'s%s",submatch(1),submatch(2),submatch(3))'
    let l:expr     = '^\(.\{-}\)\s*\('.s:php_regex_assignment.'\)\(.*\)'
    for l:line in range(a:firstline,a:lastline)
        let l:oldline = getbufline("%",l:line)[0]
        let l:newline = substitute(l:oldline,l:expr,l:formatter,"")
        call setline(l:line,l:newline)
    endfor
endfunction
" }}}

function! s:PhpDocument() " {{{
    if match(getline(line('.')-1), "*/") == -1
        normal! mr
        exec "call " . g:refactoring_toolbox_phpdoc . '()'
        normal! `r
    endif
endfunction
" }}}

function! s:PhpInsertUseStatement(use) " {{{
    let l:use = 'use ' . substitute(a:use, '^\\', '', '') . ';'
    if search(s:php_regex_use_line, 'beW') > 0
        call append(line('.'), l:use)
    elseif search(s:php_regex_ns_line, 'beW') > 0
        call append(line('.'), '')
        call append(line('.')+1, l:use)
    elseif search(s:php_regex_phptag_line, 'beW') > 0
        call append(line('.'), '')
        call append(line('.')+1, l:use)
    else
        call append(1, l:use)
    endif
endfunction
" }}}

function! s:PhpInsertProperty(name, visibility) " {{{
    let l:regex = '\%(' . join([s:php_regex_member_line, s:php_regex_const_line, s:php_regex_class_line], '\)\|\(') .'\)'
    if search(l:regex, 'beW') > 0
        let l:line = getbufline("%", line('.'))[0]
        if match(l:line, s:php_regex_class_line) > -1
            call search('{', 'W')
            call s:PhpInsertPropertyExtended(a:name, a:visibility, line('.'), 0)
        else
            call search(';', 'W')
            call s:PhpInsertPropertyExtended(a:name, a:visibility, line('.'), 1)
        endif
    else
        call search(';', 'W')
        call s:PhpInsertPropertyExtended(a:name, a:visibility, line('.'), 0)
    endif
endfunction
" }}}

function! s:PhpInsertPropertyExtended(name, visibility, insertLine, emptyLineBefore) " {{{
    call append(a:insertLine, '')
    call append(a:insertLine + a:emptyLineBefore, '/**')
    call append(a:insertLine + a:emptyLineBefore + 1, '* @var mixed')
    call append(a:insertLine + a:emptyLineBefore + 2, '*/')
    call append(a:insertLine + a:emptyLineBefore + 3, a:visibility . " $" . a:name . ';')
    normal! j=5=
endfunction
" }}}

function! s:PhpGetFQCNUnderCursor() " {{{
    let l:line = getbufline("%", line('.'))[0]
    let l:lineStart = strpart(l:line, 0, col('.'))
    let l:lineEnd   = strpart(l:line, col('.'), strlen(l:line) - col('.'))
    return matchstr(l:lineStart, s:php_regex_fqcn . '$') . matchstr(l:lineEnd, '^' . s:php_regex_cn)
endfunction
" }}}

function! s:PhpGetShortClassName(fqcn) " {{{
    return matchstr(a:fqcn, s:php_regex_cn . '$')
endfunction
" }}}

function! s:PhpGetDefaultUse(fqcn) " {{{
    return inputdialog("Use as [Default: " . s:PhpGetShortClassName(a:fqcn) ."] : ")
endfunction
" }}}

function! s:PhpPopList(list) " {{{
    for l:elem in reverse(a:list)
        if strlen(l:elem) > 0
            return l:elem
        endif
    endfor
endfunction
" }}}

function! s:PhpSearchInRange(pattern, flags, startLine, endLine) " {{{
    return search('\%>' . a:startLine . 'l\%<' . a:endLine . 'l' . a:pattern, a:flags)
endfunction
" }}}
