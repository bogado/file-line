
function! s:gotoline()
	let file = bufname("%")
	" Accept file:line:column: or file:line:column and file:line also
	let names =  matchlist( file, '\(.\{-1,}\):\(\d\+\)\(:\(\d*\):\?\)\?$')

	if len(names) != 0 && filereadable(names[1])
		let l:bufn = bufnr("%")
		exec ":e " . names[1]
		exec ":" . names[2]
		exec ":bdelete " . l:bufn
		if foldlevel(names[2]) > 0
			exec ":foldopen!"
		endif

		if (names[4] != '')
			exec "normal " . names[4] . "|"
		endif
	endif

endfunction

autocmd! BufNewFile *:* nested call s:gotoline()
