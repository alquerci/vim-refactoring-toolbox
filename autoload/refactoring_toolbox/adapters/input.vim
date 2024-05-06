call refactoring_toolbox#adapters#vim#begin_script()

function refactoring_toolbox#adapters#input#make()
    return s:self
endfunction

let s:self = #{}

function s:self.askQuestion(question, default = '')
    let l:prompt = s:makeQuestionPromptWithDefault(a:question, a:default)

    return s:askQuestionAndCollectAnswer(l:prompt, a:default)
endfunction

function s:self.askQuestionWithProposedAnswer(question, prefilledAnswer)
    let l:prompt = s:makeQuestionPrompt(a:question)

    return input(l:prompt, a:prefilledAnswer)
endfunction

function s:self.askQuestionWithProposedAnswerAndDirectoryCompletion(question, prefilledAnswer)
    let l:prompt = s:makeQuestionPrompt(a:question)

    return input(l:prompt, a:prefilledAnswer, 'dir')
endfunction

function s:makeQuestionPromptWithDefault(question, default)
    return s:makeQuestionPrompt(a:question.' ["'.a:default.'"]')
endfunction

function s:makeQuestionPrompt(question)
    return a:question.' '
endfunction

function s:askQuestionAndCollectAnswer(prompt, default)
    let l:cancelMarker = "//<Esc>"
    let l:defaultMarker = ''

    let l:answer = inputdialog(a:prompt, l:defaultMarker, l:cancelMarker)

    if l:cancelMarker == l:answer
        throw 'user_cancel'
    endif

    return l:defaultMarker == l:answer ? a:default : l:answer
endfunction

function s:self.askConfirmation(question)
    try
        return s:askUserConfirmation(a:question)
    catch /user_cancel/
        return v:false
    endtry
endfunction

function s:askUserConfirmation(question)
    let l:options = ["No", "Yes"]

    let l:answer = s:askQuestionWithOptions(a:question, options)

    return "Yes" == l:answer
endfunction

function s:askQuestionWithOptions(question, options)
    let l:textlist = s:makeTextListForQuestionWithOptions(a:question, a:options)

    let l:answer = inputlist(l:textlist)

    if 0 == l:answer
        throw 'user_cancel'
    endif

    return a:options[l:answer - 1]
endfunction

function s:makeTextListForQuestionWithOptions(question, options)
    let l:textlist = [a:question]
    let l:optionPosition = 0

    for l:option in a:options
        let l:optionPosition += 1

        call add(l:textlist, s:makeTextOption(l:optionPosition, l:option))
    endfor

    return l:textlist
endfunction

function s:makeTextOption(position, text)
    return a:position.'. '.a:text
endfunction

call refactoring_toolbox#adapters#vim#end_script()
