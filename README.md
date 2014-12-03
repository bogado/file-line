# File-line

### Plugin for vim to enable opening a file in a given line

When you open a `file:line`, for instance when copying and pasting the output
from a compiler, Vim tries to open a file with a colon in its name.

Examples:

    vim index.html:20
    vim app/models/user.rb:1337

This plugin will handle the line number (and any column numbers) after the
filename, taking you to the correct location.

This script is licensed under GPLv3 and you can contribute to it on Github at
[github.com/bogado/file-line](https://github.com/bogado/file-line).
 
## Install details

If you use `Bundle`, add this line to your `.vimrc`:

    Bundle 'bogado/file-line'

And launch `:BundleInstall` from Vim.

Or just copy the file into your plugins path (`$HOME/.vim/plugin` under
unixes).

## Configuration

There is an option to control when the plugin should get used.

If you want it to handle only files during Vim startup (when passing the files
as arguments), you can use the following setting

    let g:file_line_only_on_vimenter = 1

The default value is 0.
