# File-line

### Plugin for vim to enable opening a file in a given line

When you open a `file:line`, for instance when coping and pasting from an error from your
compiler vim tries to open a file with a colon in its name.

Examples:
  
    vim index.html:20
    vim app/models/user.rb:1337

With this little script in your plugins folder if the stuff after the colon is a number and
a file exists with the name especified before the colon vim will open this file and take you
to the line you wished in the first place. 

This script is licensed with GPLv3 and you can contribute to it on github at
[github.com/bogado/file-line](https://github.com/bogado/file-line).
 
## Install details

If you use `Bundle`, add this line to your `.vimrc`:

    Bundle 'bogado/file-line'
  
And launch `:BundleInstall` in vim.

Or just copy the file into your plugins path (`$HOME/.vim/plugin` under unixes).

