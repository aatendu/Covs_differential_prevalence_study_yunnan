setwd("D:\\everything\\r_work\\ruiya_taxids\\")

save.image("D:\\everything\\r_work\\ruiya_taxids\\accession_to_taxid.RData")

savehistory("D:\\everything\\r_work\\ruiya_taxids\\accession_to_taxid.Rhistory")

install.packages("taxonomizr")

require("taxonomizr")

#read into R the just unzipped taxonomy file downloaded from ncbi
read.accession2taxid("F:\\db_for_taxonomizer\\nucl_gb.accession2taxid", "F:\\db_for_taxonomizer\\1\\nucl_sq1file",
                     vocal = TRUE)

#make a test vector of accessions to test the package
trial = c("KY417142", "KJ473816", "KY417145")

#this code works i.e. produces taxids for the accessions but produces warnings about permisions
accessionToTaxa(trial,sqlFile = "F:\\db_for_taxonomizer\\1\\nucl_sq1file", version = 'base')

#read in the query file, containing the contig names
queries = read.table("all_queries.txt", sep = "\t", col.names = "queries")
summary(queries)

#read in the file containing queries and accessions from the original blastn output
q.acc = read.table("query_and_accession_column.txt", sep = " ", col.names = c("queries", "accession"))
summary(q.acc)
head (q.acc)

??innerjoin
require("dplyr")

#innerjoin produces a warning because queries in dframes match multiple rows in the other dframe
shorter.q.acc = inner_join(queries, q.acc, by = "queries")

#necessary to obtain the accessions selected by Ruiya for the given contigs

rm(list=ls())

all_acc = read.csv("all_acc.csv", header= FALSE, col.names = "accession")
summary(all_acc)

accessionToTaxa(all_acc$accession,sqlFile = "F:\\db_for_taxonomizer\\1\\nucl_sq1file", version = 'base')

all_acc$taxids = NA
all_acc$taxids = accessionToTaxa(all_acc$accession,sqlFile = "F:\\db_for_taxonomizer\\1\\nucl_sq1file", version = 'base')

?write.csv

write.csv(all_acc[1:445,], file = "D:\\everything\\per_date_logs\\2023\\june2023\\june5\\ruiya\\b41_new.csv", qmethod = "escape", row.names = FALSE)

write.csv(all_acc[446:528,], file = "D:\\everything\\per_date_logs\\2023\\june2023\\june5\\ruiya\\b51_new.csv", qmethod = "escape", row.names = FALSE)

write.csv(all_acc, file = "D:\\everything\\per_date_logs\\2023\\june2023\\june5\\ruiya\\all_acc.csv", qmethod = "escape", row.names = FALSE)

#the code above was all fine despite the warnings. Only issue being the ordering of the pools seems to have been changed at some point

rm(list=ls())
