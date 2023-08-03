"
" VIM PHP Refactoring Toolbox
"
" Maintainer: Pierrick Charron <pierrick@adoy.net>
" URL: https://github.com/adoy/vim-php-refactoring-toolbox
" License: MIT
" Version: 1.0.3
"

if exists('g:vim_php_refactoring_loaded')
    finish
endif
let g:vim_php_refactoring_loaded = 1

" Config {{{
" VIM function to call to document the current line
if !exists('g:vim_php_refactoring_phpdoc')
    let g:vim_php_refactoring_phpdoc = 'PhpDoc'
endif

if !exists('g:vim_php_refactoring_usage_logdir')
    let g:vim_php_refactoring_usage_logdir = getenv('HOME').'/.vim/log/vim-php-refactoring-toolbox'
endif

if !exists('g:vim_php_refactoring_use_default_mapping')
    let g:vim_php_refactoring_use_default_mapping = 1
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

if !exists('g:vim_php_refactoring_default_property_visibility')
    let g:vim_php_refactoring_default_property_visibility = 'private'
endif

if !exists('g:vim_php_refactoring_default_method_visibility')
    let g:vim_php_refactoring_default_method_visibility = 'private'
endif

if !exists('g:vim_php_refactoring_make_setter_fluent')
    let g:vim_php_refactoring_make_setter_fluent = 0
endif
" }}}

" Refactoring mapping {{{
if g:vim_php_refactoring_use_default_mapping == 1
    nnoremap <unique> <Leader>rlv :call PhpRenameLocalVariable()<Enter>
    nnoremap <unique> <Leader>rcv :call PhpRenameClassVariable()<Enter>
    nnoremap <unique> <Leader>rd :call PhpRenameDirectory()<Enter>
    nnoremap <unique> <Leader>eu :call PhpExtractUse()<Enter>
    nnoremap <unique> <Leader>rm :call PhpRenameMethod()<Enter>
    vnoremap <unique> <Leader>ec :call PhpExtractConst()<Enter>
    vnoremap <unique> <Leader>ev :call PhpExtractVariable()<Enter>
    nnoremap <unique> <Leader>iv :call PhpInlineVariable()<Enter>
    nnoremap <unique> <Leader>ep :call PhpExtractClassProperty()<Enter>
    vnoremap <unique> <Leader>em :call PhpExtractMethod()<Enter>
    nnoremap <unique> <Leader>np :call PhpCreateProperty()<Enter>
    nnoremap <unique> <Leader>du :call PhpDetectUnusedUseStatements()<Enter>
    vnoremap <unique> <Leader>== :call PhpAlignAssigns()<Enter>
    nnoremap <unique> <Leader>sg :call PhpCreateSettersAndGetters()<Enter>
    nnoremap <unique> <Leader>cog :call PhpCreateGetters()<Enter>
    nnoremap <unique> <Leader>da :call PhpDocAll()<Enter>
endif
" }}}

fun s:incrementUsage(name)
    call php_refactoring_toolbox#usage#increment(a:name)
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
let s:php_regex_class_line  = php_refactoring_toolbox#regex#class_line
let s:php_regex_const_line = php_refactoring_toolbox#regex#const_line
let s:php_regex_member_line = php_refactoring_toolbox#regex#member_line
let s:php_regex_func_line = php_refactoring_toolbox#regex#func_line

let s:php_regex_assignment  = '+=\|-=\|*=\|/=\|=\~\|!=\|='
let s:php_regex_fqcn        = '[\\_A-Za-z0-9]*'
let s:php_regex_cn          = '[_A-Za-z0-9]\+'
" }}}

function! PhpCreateGetters() " {{{
    call s:incrementUsage('PhpCreateGetters')

    call php_refactoring_toolbox#create_getter_and_setter#createOnlyGetters()
endfunction
" }}}

function! PhpCreateSettersAndGetters() " {{{
    call s:incrementUsage('PhpCreateSettersAndGetters')

    call php_refactoring_toolbox#create_getter_and_setter#execute()
endfunction
" }}}

function! PhpExtractMethod() range " {{{
    call s:incrementUsage('PhpExtractMethod')

    call php_refactoring_toolbox#extract_method#execute()
endfunction
" }}}

function! PhpRenameLocalVariable() " {{{
    call s:incrementUsage('PhpRenameLocalVariable')

    call php_refactoring_toolbox#rename_variable#execute()
endfunction
" }}}

function! PhpInlineVariable() " {{{
    call s:incrementUsage('PhpInlineVariable')

    call php_refactoring_toolbox#inline_variable#execute()
endfunction
" }}}

function! PhpRenameDirectory() " {{{
    call s:incrementUsage('PhpRenameDirectory')

    call php_refactoring_toolbox#rename_directory#execute()
endfunction
" }}}

function! PhpDocAll() " {{{
    call s:incrementUsage('PhpDocAll')

    if exists("*" . g:vim_php_refactoring_phpdoc) == 0
        call s:PhpEchoError(g:vim_php_refactoring_phpdoc . '() vim function doesn''t exists.')
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

function! PhpRenameClassVariable() " {{{
    call s:incrementUsage('PhpRenameClassVariable')

    let l:oldName = substitute(expand('<cword>'), '^\$*', '', '')
    let l:newName = inputdialog('Rename ' . l:oldName . ' to: ')
    if g:vim_php_refactoring_auto_validate_rename == 0
        if s:PhpSearchInCurrentClass('\C\%(\%(\%(public\|protected\|private\|static\)\%(\_s\+?\?[\\|_A-Za-z0-9]\+\)\?\_s\+\)\+\$\|$this->\)\@<=' . l:newName . '\>', 'n') > 0
            call s:PhpEchoError(l:newName . ' seems to already exist in the current class. Rename anyway ?')
            if inputlist(["0. No", "1. Yes"]) == 0
                return
            endif
        endif
    endif
    call s:PhpReplaceInCurrentClass('\C\%(\%(\%(public\|protected\|private\|static\)\%(\_s\+?\?[\\|_A-Za-z0-9]\+\)\?\_s\+\)\+\$\|$this->\)\@<=' . l:oldName . '\>', l:newName)
endfunction
" }}}

function! PhpRenameMethod() " {{{
    call s:incrementUsage('PhpRenameMethod')

    let l:oldName = substitute(expand('<cword>'), '^\$*', '', '')
    let l:newName = inputdialog('Rename ' . l:oldName . ' to: ')
    if g:vim_php_refactoring_auto_validate_rename == 0
        if s:PhpSearchInCurrentClass('\%(\%(' . s:php_regex_func_line . '\)\|$this->\)\@<=' . l:newName . '\>', 'n') > 0
            call s:PhpEchoError(l:newName . ' seems to already exist in the current class. Rename anyway ?')
            if inputlist(["0. No", "1. Yes"]) == 0
                return
            endif
        endif
    endif
    call s:PhpReplaceInCurrentClass('\%(\%(' . s:php_regex_func_line . '\)\|$this->\)\@<=' . l:oldName . '\>', l:newName)
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

function! PhpExtractConst() " {{{
    call s:incrementUsage('PhpExtractConst')

    if visualmode() != 'v'
        call s:PhpEchoError('Extract constant only works in Visual mode, not in Visual Line or Visual block')
        return
    endif
    let l:name = toupper(inputdialog("Name of new const: "))
    normal! mrgv"xy
    call s:PhpReplaceInCurrentClass(@x, 'self::' . l:name)
    call s:PhpInsertConst(l:name, @x)
    normal! `r
endfunction
" }}}

function! PhpExtractVariable() " {{{
    call s:incrementUsage('PhpExtractVariable')

    if visualmode() != 'v'
        call s:PhpEchoError('Extract variable only works in Visual mode, not in Visual Line or Visual block')
        return
    endif

    " input
    let l:name = inputdialog('Name of new variable: ')
    let l:defaultUpwardMove = 1
    let l:lineUpwardForAssignment = inputdialog('Line upward for assignment (default is '.l:defaultUpwardMove.'): ')
    if empty(l:lineUpwardForAssignment)
        let l:lineUpwardForAssignment = l:defaultUpwardMove
    endif

    " go to select and copy and delete
    normal! gvx

    " add marker
    normal! mr

    " type variable name
    exec 'normal! i$'.l:name

    " go to start on selection
    normal! `r

    " getcurpos()
    let l:startLine = line('.')
    let l:startCol = col('.')

    " go to line to write assignment
    call cursor(line('.') - l:lineUpwardForAssignment, 0)
    let l:indentChars = indent(nextnonblank(line('.') + 1))
    let l:needBlankLineAfter = v:false

    " line ends with ,
    while s:currentLineEndsWith(',')
        call s:backwardOneLine()
    endwhile

    " line ends with [
    if s:currentLineEndsWith('[')
        call s:backwardOneLine()
    endif

    if empty(trim(getline(line('.'))))
        let l:currentLine = line('.')
        let l:currentCol = col('.')

        call cursor(nextnonblank(l:currentLine), 0)
        let l:indentChars = indent(line('.'))

        call cursor(prevnonblank(l:currentLine), l:currentCol)

        let l:lineUpwardForAssignment = l:currentLine - l:startLine
    endif

    if 1 == l:lineUpwardForAssignment
        let l:needBlankLineAfter = v:true
    endif

    " type variable assignment
    let l:prefixAssign = repeat(' ', l:indentChars).'$'.l:name.' = '
    call append(line('.'), l:prefixAssign)

    " move cursor after the equal sign
    call cursor(line('.') + 1, 0)
    normal! $

    " paste selection and add semi-colon
    normal! pa;

    if l:needBlankLineAfter
        call append(line('.'), '')
    endif

    " go to start on selection
    normal! `r
endfunction
" }}}

function! PhpExtractClassProperty() " {{{
    call s:incrementUsage('PhpExtractClassProperty')

    normal! mr
    let l:name = substitute(expand('<cword>'), '^\$*', '', '')
    call s:PhpReplaceInsideCurrentFunctionBody('$' . l:name . '\>', '$this->' . l:name)
    if g:vim_php_refactoring_auto_validate_visibility == 0
        let l:visibility = inputdialog("Visibility (default is " . g:vim_php_refactoring_default_property_visibility . "): ")
        if empty(l:visibility)
            let l:visibility =  g:vim_php_refactoring_default_property_visibility
        endif
    else
        let l:visibility =  g:vim_php_refactoring_default_property_visibility
    endif
    call s:PhpInsertProperty(l:name, l:visibility)
    normal! `r
endfunction
" }}}

function! s:PhpReplaceInsideCurrentFunctionBody(search, replace) " {{{
    normal! mr

    call search(s:php_regex_func_line, 'bW')
    call search('{', 'W')
    let l:startLine = line('.')
    call searchpair('{', '', '}', 'W')
    let l:stopLine = line('.')

    exec l:startLine . ',' . l:stopLine . ':s/' . a:search . '/'. a:replace .'/ge'
    normal! `r
endfunction
" }}}

function! PhpCreateProperty() " {{{
    call s:incrementUsage('PhpCreateProperty')

    let l:name = inputdialog("Name of new property: ")
    if g:vim_php_refactoring_auto_validate_visibility == 0
        let l:visibility = inputdialog("Visibility (default is " . g:vim_php_refactoring_default_property_visibility . "): ")
        if empty(l:visibility)
            let l:visibility =  g:vim_php_refactoring_default_property_visibility
        endif
    else
        let l:visibility =  g:vim_php_refactoring_default_property_visibility
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
        exec "call " . g:vim_php_refactoring_phpdoc . '()'
        normal! `r
    endif
endfunction
" }}}

function! s:PhpReplaceInCurrentClass(search, replace) " {{{
    normal! mr

    call search(s:php_regex_class_line, 'beW')
    call search('{', 'W')
    let l:startLine = line('.')
    call searchpair('{', '', '}', 'W')
    let l:stopLine = line('.')

    exec l:startLine . ',' . l:stopLine . ':s/' . a:search . '/'. a:replace .'/ge'
    normal! `r
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

function! s:PhpInsertConst(name, value) " {{{
    if search(s:php_regex_const_line, 'beW') > 0
        call append(line('.'), 'const ' . a:name . ' = ' . a:value . ';')
    elseif search(s:php_regex_class_line, 'beW') > 0
        call search('{', 'W')
        call append(line('.'), 'const ' . a:name . ' = ' . a:value . ';')
        call append(line('.')+1, '')
    else
        call append(line('.'), 'const ' . a:name . ' = ' . a:value . ';')
    endif
    normal! j=1=
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

function! s:PhpSearchInCurrentClass(pattern, flags) " {{{
    normal! mr
    call search(s:php_regex_class_line, 'beW')
    call search('{', 'W')
    let l:startLine = line('.')
    exec "normal! %"
    let l:stopLine = line('.')
    normal! `r
    return s:PhpSearchInRange(a:pattern, a:flags, l:startLine, l:stopLine)
endfunction
" }}}

function! s:PhpSearchInRange(pattern, flags, startLine, endLine) " {{{
    return search('\%>' . a:startLine . 'l\%<' . a:endLine . 'l' . a:pattern, a:flags)
endfunction
" }}}

function! s:PhpEchoError(message) " {{{
    echohl ErrorMsg
    echomsg a:message
    echohl NONE
endfunction
" }}}

function! s:currentLineEndsWith(char) " {{{
    return a:char == trim(getline(line('.')))[-1:]
endfunction
" }}}

function! s:backwardOneLine() " {{{
    call cursor(line('.') - 1, 0)
endfunction
" }}}
