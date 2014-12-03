" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_file_line') || (v:version < 701)
	finish
endif
let g:loaded_file_line = 1

if !exists('g:file_line_only_on_enter')
	let g:file_line_only_on_vimenter = 0
endif

" list with all possible expressions :
"	 matches file(10) or file(line:col)
"	 Accept file:line:column: or file:line:column and file:line also
let s:regexpressions = [ '\([^(]\{-1,}\)(\%(\(\d\+\)\%(:\(\d*\):\?\)\?\))', '\(.\{-1,}\):\%(\(\d\+\)\%(:\(\d*\):\?\)\?\)\?' ]

function! s:reopenAndGotoLine(file_name, line_num, col_num)
	if !filereadable(a:file_name)
		return
	endif

	" Remove the original buffer when it's no longer visible.
	" This does not break `vim -[poO]`, as with `:bwipeout`.
	set bufhidden=wipe

	exec "keepalt edit " . fnameescape(a:file_name)
	exec a:line_num
	exec "normal! " . a:col_num . '|'
	if foldlevel(a:line_num) > 0
		normal! zv
	endif
	normal! zz
endfunction

function! s:gotoline()
	if g:file_line_only_on_vimenter && !has('vim_starting')
		return
	endif
	let file = bufname("%")

	" :e command calls BufRead even though the file is a new one.
	" As a workaround Jonas Pfenniger<jonas@pfenniger.name> added an
	" AutoCmd BufRead, this will test if this file actually exists before
	" searching for a file and line to goto.
	if (filereadable(file) || file == '')
		return
	endif

	let l:names = []
	for regexp in s:regexpressions
		let l:names =  matchlist(file, regexp)

		if ! empty(l:names)
			let file_name = l:names[1]
			let line_num  = l:names[2] == ''? '0' : l:names[2]
			let  col_num  = l:names[3] == ''? '0' : l:names[3]
			call s:reopenAndGotoLine(file_name, line_num, col_num)
			return
		endif
	endfor
endfunction

augroup file_line
	au!
	autocmd BufNewFile  * nested call s:gotoline()
	autocmd BufReadPost * nested call s:gotoline()
augroup END
