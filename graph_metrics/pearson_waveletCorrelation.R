library(waveslim)
library(stringr)

# function to perform Fisher R to Z transform
doFtoZ <- function(waveletlvl,adjMats,naList){
 rho = adjMats[[waveletlvl]]

 # Remove NA columns
 for(i in naList){
   rho[i,] <- c(NA)
   rho[,i] <- c(NA)
 }

 # write raw correlations
 outFile = paste(paste("adjMat",
                       str_pad(nrow(rho), 3, pad="0"),
                       gsub("[.]", "_", waveletlvl),
                       sep="_"),
                 ".txt",
                 sep="")
 write.table(rho, outFile, col.names=FALSE, row.names=FALSE)

 # set diagonal to NA
 for(x in seq(length(rho[1,]))){
  for(y in seq(length(rho[,1]))){
   if(x == y){
    rho[x,y] = NA
   }
  }
 }

 rho <- 0.5*log((1+rho)/(1-rho))

 # write Fisher corrected correlations
 outFile = paste(paste("adjMat",
                       str_pad(nrow(rho), 3, pad="0"),
                       gsub("[.]", "_", waveletlvl),
                       "fcorr",
                       sep="_"),
                 ".txt",
                 sep="")
 write.table(rho, outFile, col.names=FALSE, row.names=FALSE)
 return(rho)
}


doPearson <- function(ts.name) {
 ts <- read.table(ts.name) # import timeseries
 ts.mat <- as.matrix(ts) # convert dataframe to matrix

 # get a list of NA columns
 naList <- which(is.na(ts.mat[,1]))

 # get rid of NANs
 ts.mat[is.na(ts.mat)] <- 999.

 # define output directory
 parcelDir = strsplit(ts.name, "[.]")[[1]][[1]]

 # create the outputdirectory
 dir.create(parcelDir, showWarnings=FALSE)

 # go to subject's directory
 setwd(parcelDir)

 # obtain Pearson corrrelation coefficients and p-value maps
 N = dim(ts.mat)[1]
 k = dim(ts.mat)[2]

 # output matrices
 out_mats = list("pearson" = matrix(NA, nrow = N, ncol = N),
                 "p" = matrix(NA, nrow = N, ncol = N))

 for (i in 1:N){
  for (j in i:N){
   pearson_corr <- cor.test(ts.mat[i,], ts.mat[j,])

   # save the correlation
   out_mats$pearson[i,j] <- pearson_corr$estimate
   out_mats$pearson[j,i] <- pearson_corr$estimate

   # save the p-value
   out_mats$p[i,j] <- pearson_corr$p.value
   out_mats$p[j,i] <- pearson_corr$p.value
  }
 }

 # Fisher transform and save Pearson correlation coefficient
 doFtoZ("pearson", out_mats, naList)

 # save p-value map
 # Remove NA columns
 for(i in naList){
   out_mats$p[i,] <- c(NA)
   out_mats$p[,i] <- c(NA)
 }

 # write to file
 outFile = paste(paste("adjMat",
                       str_pad(nrow(out_mats$p), 3, pad="0"),
                       "pvalue",
                       sep="_"),
                 ".txt",
                 sep="")
 write.table(out_mats$p, outFile, col.names=FALSE, row.names=FALSE)

 # return to the working directory
 setwd("../")
}


doPearson("hammers_reparcelled_ts.txt")

