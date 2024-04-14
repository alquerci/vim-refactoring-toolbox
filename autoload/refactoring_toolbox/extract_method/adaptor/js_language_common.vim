call refactoring_toolbox#adaptor#vim#begin_script()

let s:regex_before_word_boudary = refactoring_toolbox#adaptor#regex#before_word_boudary
let s:regex_after_word_boudary = refactoring_toolbox#adaptor#regex#after_word_boudary

let s:SEARCH_NOT_FOUND = 0

function refactoring_toolbox#extract_method#adaptor#js_language_common#make(position)
    let s:position = a:position

    return s:self
endfunction

let s:self = #{}

function s:self.getTopLineOfMethodWithPatternFromPosition(pattern, position)
    let l:potentialTopPosition = a:position
    let l:found = v:false

    while v:true
        try
            let l:potentialTopPosition = s:searchPositionBackwardWithPatternFromPosition(a:pattern, l:potentialTopPosition)

            let l:bottomPosition = s:getClosingPositionBracketFromPosition(l:potentialTopPosition)

            if s:position.positionIsAfterPosition(l:bottomPosition, a:position)
                let l:foundPosition = l:potentialTopPosition

                let l:found = v:true
            endif
        catch /search_not_found/
            if l:found
                return l:foundPosition
            else
                throw 'top_line_not_found'
            endif
        endtry
    endwhile
endfunction

function s:searchPositionBackwardWithPatternFromPosition(pattern, position)
    call s:position.moveToPosition(a:position)

    if s:SEARCH_NOT_FOUND == search(a:pattern, 'bW')
        call s:position.backToPreviousPosition()

        throw 'search_not_found'
    endif

    let l:findPosition = s:position.getCurrentPosition()

    call s:position.backToPreviousPosition()

    return l:findPosition
endfunction

function s:self.getBottomPositionOfMethodWithPosition(self, position)
    let l:topPosition = a:self.getTopPositionOfMethodWithPosition(a:position)

    return s:getClosingPositionBracketFromPosition(l:topPosition)
endfunction

function s:getClosingPositionBracketFromPosition(position)
    call s:position.moveToPosition(a:position)

    call s:searchOpenBracketThenMoveToClosingFromCurrentPosition()
    let l:closingPosition = s:position.getCurrentPosition()

    call s:position.backToPreviousPosition()

    return l:closingPosition
endfunction

function s:searchOpenBracketThenMoveToClosingFromCurrentPosition()
    call search('{', 'W')
    call searchpair('{', '', '}', 'W')
endfunction

function s:self.makePatternForVariableName(name)
    return s:regex_before_word_boudary.a:name.s:regex_after_word_boudary
endfunction

call refactoring_toolbox#adaptor#vim#end_script()
