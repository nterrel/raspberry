# Some useful commands that I might not remember off the top of my head

## Append text to the bottom of a file

`echo "Text to append" >> filename.txt`

Note that using only `>` instead of `>>` will overwrite.

## System boot information
```
systemd-analyze time
systemd-analyze blame | head -n 20
```


