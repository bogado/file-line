" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_file_line') || (v:version < 701)
	finish
endif
let g:loaded_file_line = 1

" list with all possible expressions :
"	 matches file(10) or file(line:col)
"	 Accept file:line:column: or file:line:column and file:line also
let s:regexpressions = [ '\([^(]\{-1,}\)(\%(\(\d\+\)\%(:\(\d*\):\?\)\?\))', '\(.\{-1,}\):\%(\(\d\+\)\%(:\(\d*\):\?\)\?\)\?' ]

function! s:reopenAndGotoLine(file_name, line_num, col_num)
	if !filereadable(a:file_name)
		return
	endif

	let l:bufn = bufnr("%")

	exec "keepalt edit " . fnameescape(a:file_name)
	exec a:line_num
	exec "normal! " . a:col_num . '|'
	if foldlevel(a:line_num) > 0
		exec "normal! zv"
	endif
	exec "normal! zz"

	exec "bwipeout " l:bufn
	exec "filetype detect"
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
			break
		endif
	endfor
endfunction

function s:startup()
	autocmd! BufNewFile * nested call s:gotoline()
	autocmd! BufRead * nested call s:gotoline()
	silent! bufdo call s:gotoline()
	silent! bfirst
	doautocmd FileType
	doautocmd BufEnter
	if &diff
		diffthis
	endif
endfunction

autocmd VimEnter * call s:startup()
