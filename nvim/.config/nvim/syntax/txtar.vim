if exists('b:current_syntax')
  finish
endif

lua require('txtar').apply(0)

let b:current_syntax = 'txtar'
