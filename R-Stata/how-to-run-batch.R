Create a sh-file what will start R job

cd /home/svesan/ki/ABS/mep/sasproj/PSY/PSY1203/R-Stata/

vi cousins_batch1.sh

R CMD BATCH /home/svesan/ki/ABS/mep/sasproj/PSY/PSY1203/R-Stata/s_psy1203_cox_cousins_08.R



Then put in que

at -fm cousins_batch3.sh -v 12:16


atq to see the que