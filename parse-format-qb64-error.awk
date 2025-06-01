{
    # script to convert qb64.exe output from this
    #
    # Syntax error
    # Caused by (or after):IM SHARED VERTWALL ( MAXWALLTILES ) AS INTEGER
    # LINE 74:im Shared vertwall(MAXWALLTILES) As Integer
    #
    # to
    # LINE 74: Syntax error: im Shared vertwall(MAXWALLTILES) As Integer

    # file ~/.config/nvim/filetype.vim
    #
    # au BufRead,BufNewFile *.bas,*.bi,*.bm,*.BAS,*.BI,*.BM set filetype=qb64
    #

    # changes in ~/.config/nvim/lua/polish.lua
    # vim.cmd([[
    #   augroup qb64bas
    #       autocmd!
    #       autocmd FileType qb64 set errorformat=LINE\ %l:%m|set makeprg=./mymake.sh
    #   augroup END
    #   ]])

    # Windows line end output ^M
    # Remove carriage return at end of line, if present
    sub(/\r+$/, "")
    sub(/\r/, "")

    prev3 = prev2
    prev2 = prev1
    prev1 = $0

    if ($0 ~ /^LINE[[:space:]]*[0-9]+:/) {
        # Extract the line number
        match($0, /^LINE[[:space:]]*([0-9]+):/, arr)
        lineno = arr[1]
        # Extract the message after the colon
        sub(/^LINE[[:space:]]*[0-9]+:[[:space:]]*/, "", $0)
        message = $0
        # Output in the desired format
        print "LINE " lineno ": " prev3 ": " message
    } else {
        print $0
    }
}
