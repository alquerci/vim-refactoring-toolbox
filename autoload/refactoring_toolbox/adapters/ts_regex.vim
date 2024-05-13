let s:mutation_symbols = refactoring_toolbox#adapters#js_regex#mutation_symbols
let s:var_name = refactoring_toolbox#adapters#js_regex#var_name

call refactoring_toolbox#adapters#vim#begin_script()

let s:before_word_boundary = '\<'

let s:regex_type_hint = '\%(\w\||\)\+'
let s:regex_return_type_hint = ':\_s*'.s:regex_type_hint
let s:regex_method_line = '\w([^)]*)\_s*\%('.s:regex_return_type_hint.'\)\?\_s*{$'
let s:regex_function_line = s:before_word_boundary.'function\_s\+\w*\_s*([^)]*)\_s*\%('.s:regex_return_type_hint.'\)\?\_s*{$'
let s:regex_arrow_func_line = '\%('.s:var_name.'\|([^)]*)\)\_s*\%('.s:regex_return_type_hint.'\)\?\_s*=>'

let refactoring_toolbox#adapters#ts_regex#var_name = s:var_name
let refactoring_toolbox#adapters#ts_regex#mutation_symbols = s:mutation_symbols
let refactoring_toolbox#adapters#ts_regex#func_line = '\%('.s:regex_arrow_func_line.'\|'.s:regex_method_line.'\|'.s:regex_function_line.'\)'

call refactoring_toolbox#adapters#vim#end_script()
