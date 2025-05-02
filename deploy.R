#!/usr/bin/env Rscript
# render the whole site, commit everything, push

system("quarto render")
system("git add -A")
msg <- sprintf('site update %s', Sys.time())
system(sprintf("git commit -m \"%s\"", msg))
system("git push")
