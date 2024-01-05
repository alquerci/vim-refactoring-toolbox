call refactoring_toolbox#adaptor#vim#begin_script()

let s:regex_before_word_boudary = refactoring_toolbox#adaptor#regex#before_word_boudary
let s:regex_after_word_boudary = refactoring_toolbox#adaptor#regex#after_word_boudary

function refactoring_toolbox#extract_method#adaptor#js_language_common#make(position)
    let s:position = a:position

    return s:self
endfunction

let s:self = #{}

function s:self.searchPositionBackwardWithPatternFromPosition(pattern, position)
    call s:position.moveToPosition(a:position)

    call search(a:pattern, 'bW')
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
