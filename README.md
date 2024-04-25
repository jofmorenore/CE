# CE
pkgs = c("config", "dplyr", "ggplot2", "httr2",
         "stringr", "xml2", "epitrix", "sf",
         "readxl", "sysfonts", "showtext", "cowplot", "gridExtra",
         "kableExtra", "knitr", "rmarkdown")

for (i in pkgs){
  install.packages(i)
}

row.names(installed.packages())[row.names(installed.packages()) %in% pkgs]

install.packages("pak")

pak::pak("epiverse-trace/sivirep")
