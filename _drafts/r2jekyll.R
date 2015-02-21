#!/usr/bin/env Rscript
library(knitr)

# Get the filename given as an argument in the shell.
args = commandArgs(TRUE)
filename = args[1]

# Check that it's a .Rmd file.
if(!grepl(".Rmd", filename)) {
  stop("You must specify a .Rmd file.")
}

#opts_knit$set(base.url = "http://headsphere.github.io")
fig.path <- paste0("images/", sub(".Rmd$", "", filename), "/")
opts_chunk$set(fig.path = fig.path)
opts_chunk$set(fig.cap = "center")

render_jekyll(highlight = "pygments")

# Knit and place in _posts.
dir = paste0("../_posts/", Sys.Date(), "-")
output = paste0(dir, sub('.Rmd', '.md', filename))
knit(filename, output)

# Copy .png files to the images directory.
fromdir = "{{ site.url }}/images"
todir = "../images"

pics = list.files(fromdir, ".png|.jpg")
pics = sapply(pics, function(x) paste(fromdir, x, sep="/"))
file.copy(pics, todir, overwrite = TRUE)

#http://0.0.0.0:4000/images/exploring-the-cars-dataset-cars-plot-1.png
#http://0.0.0.0:4000/2015/02/21/exploring-the-cars-dataset/images/sequential_trade_model.jpg
