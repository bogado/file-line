" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_file_line') || (v:version < 701)
	finish
endif
let g:loaded_file_line = 1

" below regexp will separate filename and line/column number
" possible inputs to get to line 10 (and column 99) in code.cc are:
" * code.cc(10)
" * code.cc(10:99)
" * code.cc:10
" * code.cc:10:99
"
" closing braces/colons are ignored, so also acceptable are:
" * code.cc(10
" * code.cc:10:
let s:regexpressions = [ '\(.\{-1,}\)[(:]\(\d\+\)\%(:\(\d\+\):\?\)\?' ]

function! s:reopenAndGotoLine(file_name, line_num, col_num)
	if !filereadable(a:file_name)
		return
	endif

	let l:bufn = bufnr("%")

	silent! exec "keepalt edit " . fnameescape(a:file_name)
	silent! exec a:line_num
	silent! exec "normal! " . a:col_num . '|'
	if foldlevel(a:line_num) > 0
		silent! exec "normal! zv"
	endif
	silent! exec "normal! zz"

	silent! exec "bwipeout " l:bufn
	silent! exec "filetype detect"
endfunction

function! s:gotoline()
	let file = bufname("%")

	" :e command calls BufRead even though the file is a new one.
	" As a workaround Jonas Pfenniger<jonas@pfenniger.name> added an
	" AutoCmd BufRead, this will test if this file actually exists before
	" searching for a file and line to goto.
	if (filereadable(file) || file == '')
		return file
	endif

	let l:names = []
	for regexp in s:regexpressions
		let l:names =  matchlist(file, regexp)

		if ! empty(l:names)
			let file_name = l:names[1]
			let line_num  = l:names[2] == ''? '0' : l:names[2]
			let  col_num  = l:names[3] == ''? '0' : l:names[3]
			call s:reopenAndGotoLine(file_name, line_num, col_num)
			return file_name
		endif
	endfor
	return file
endfunction

" Handle entry in the argument list.
" This is called via `:argdo` when entering Vim.
function! s:handle_arg()
	let argname = expand('%')
	let fname = s:gotoline()
	if fname != argname
		let argidx = argidx()
		silent! exec (argidx+1).'argdelete'
		silent! exec (argidx)'argadd' fnameescape(fname)
	endif
endfunction

function! s:startup()
	autocmd BufNewFile * nested call s:gotoline()
	autocmd BufRead * nested call s:gotoline()

	if argc() > 0
		let argidx=argidx()
		silent argdo call s:handle_arg()
		silent! exec (argidx+1).'argument'
		" Manually call Syntax autocommands, ignored by `:argdo`.
		doautocmd Syntax
		doautocmd FileType
	endif
endfunction

autocmd VimEnter * call s:startup()
