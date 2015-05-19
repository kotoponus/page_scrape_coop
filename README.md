This is an rudimentary attempt to scrape transcation data from Coop Bank site once you logged in.  Not in a good shape, but at least a start.

In order to run, you need a folder in the same level as the scrape.pl file named in $directory ("data" by default).  There you place all the transactional html files you save from the website.

Then you run the scrape.pl file and hopefully you get the result file with the data in comma delimited format as named in $result_file ("result" by default).  

Also, you can run on only a few files like:

me> /home/user/page_scrape perl scrape.pl data/file1.html data/file2.html 


