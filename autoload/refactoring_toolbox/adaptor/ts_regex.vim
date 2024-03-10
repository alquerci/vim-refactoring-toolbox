let refactoring_toolbox#adaptor#ts_regex#mutation_symbols = refactoring_toolbox#adaptor#js_regex#mutation_symbols
let refactoring_toolbox#adaptor#ts_regex#var_name = refactoring_toolbox#adaptor#js_regex#var_name

call refactoring_toolbox#adaptor#vim#begin_script()

let s:regex_type_hint = '\%(\w\||\)\+'
let s:regex_return_type_hint = ':\_s*'.s:regex_type_hint
let s:regex_method_line = '\w([^)]*)\_s*\%('.s:regex_return_type_hint.'\)\?\_s*{$'
let s:regex_arrow_func_line = '=>'
let refactoring_toolbox#adaptor#ts_regex#func_line = '\%('.s:regex_arrow_func_line.'\|'.s:regex_method_line.'\)'

call refactoring_toolbox#adaptor#vim#end_script()
