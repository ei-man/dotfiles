if exists('b:current_syntax')
  finish
endif

" Comment lines (# at start of line)
syn match txtarComment /^#.*$/

" Archive file headers: -- filename.ext --
syn match txtarFileHeader /^-- .\+ --$/

" Script commands (first word on a line, before first archive header)
syn match txtarCommand /^\w[[:alnum:]-]*/ contained
syn match txtarNegatedLine /^!\s*\w[[:alnum:]-]*/ contained contains=txtarNegation,txtarNegatedCommand
syn match txtarNegation /^!/ contained
syn match txtarNegatedCommand /\w[[:alnum:]-]*/ contained

" Script section: everything before the first archive header
syn region txtarScript start="\%^" end="^-- .\+ --$"me=s-1 contains=txtarComment,txtarCommand,txtarNegatedLine keepend

hi def link txtarComment Comment
hi def link txtarFileHeader Title
hi def link txtarCommand Keyword
hi def link txtarNegatedCommand Keyword
hi def link txtarNegation WarningMsg

let b:current_syntax = 'txtar'

" Load embedded syntax injection for archive file contents
lua require('txtar-syntax').inject()
