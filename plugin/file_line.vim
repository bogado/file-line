" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_file_line') || (v:version < 701)
	finish
endif
let g:loaded_file_line = 1

function! s:gotoline()
	let file = bufname("%")

	" :e command calls BufRead even though the file is a new one.
	" As a workarround Jonas Pfenniger<jonas@pfenniger.name> added an
	" AutoCmd BufRead, this will test if this file actually exists before
	" searching for a file and line to goto.
	if (filereadable(file))
		return
	endif

	" Look for file(line), file(line:col).
	" Done first, because the colon part could match below.
	" Matches any non-( chars, the numbers, ")"" and optional "trash" at then.
	let names =  matchlist( file, '\([^(]*\)(\%(\(\d\+\)\%(:\(\d*\):\?\)\?\))\?[^:) ]\{-}$')

	if empty(names)
		" Accept file:line:column: or file:line:column and file:line also
		" Matches any non-: chars, then the numbers and optional "trash" at then.
		let names =  matchlist( file, '\([^:]*\):\%(\(\d\+\)\%(:\(\d*\):\?\)\?\)\?[^: ]\{-}$')

		if empty(names)
			return
		end
	endif

	let file_name = names[1]
	let line_num  = names[2] == ''? '0' : names[2]
	let  col_num  = names[3] == ''? '0' : names[3]

	if filereadable(file_name)
		let l:bufn = bufnr("%")

		exec "keepalt edit " . fnameescape(file_name)
		exec ":" . line_num
		exec "normal! " . col_num . '|'
		if foldlevel(line_num) > 0
			exec "normal! zv"
		endif
		exec "normal! zz"

		exec ":bwipeout " l:bufn
		exec ":filetype detect"
	endif

endfunction

autocmd! BufNewFile *:* nested call s:gotoline()
autocmd! BufRead *:* nested call s:gotoline()
