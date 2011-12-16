" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_file_line') || (v:version < 700)
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

	" Accept file:line:column: or file:line:column and file:line also
	let names =  matchlist( file, '\(.\{-1,}\):\(\d\+\)\(:\(\d*\):\?\)\?$')

	if len(names) != 0 && filereadable(names[1])
		let l:bufn = bufnr("%")
		exec "keepalt edit " . names[1]
		exec ":" . names[2]
		exec ":bwipeout " l:bufn
		if foldlevel(names[2]) > 0
			exec ":foldopen!"
		endif

		if (names[4] != '')
			exec "normal! " . names[4] . '|'
		endif
	endif

endfunction

autocmd! BufNewFile *:* nested call s:gotoline()
autocmd! BufRead *:* nested call s:gotoline()
