function! s:gotoline()
	let buf = bufnr("%")
	let file = bufname("%")
	let names =  matchlist( file, '\(.*\):\(\d\+\)')

	if len(names) != 0 && filereadable(names[1])
		exec ":sp " . names[1]
		exec ":" . names[2]
		exec "buffer " . buf
		exec ":q"
		exec "buffer " . bufnr(names[1])
	endif

endfunction

autocmd! BufNewFile *:* call s:gotoline()
