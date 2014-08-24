
README.MD
=========

Data cleansing course project;

Run_analysisv2.R is the R Script used to create combined workset.

To run script:
1.Download and unzip data from links provided;
2. Uncompresses data under: "getdata-projectfiles-UCI HAR Dataset" directory;
3. Set Working Directory in R to "getdata-projectfiles-UCI HAR Dataset"
4.Install Script in Working directory;
5. Run script in this directory

Reads following files:
- Activity Labels
- Features
- Training Data set
- Test Data set

Combines Training Data set and Test Data set. After combining converts activity numbers to descriptive labels.  Provides column labels by extracting Mean() and Std() of measures from the features.txt file.  Separates these columns from the rest in the combined data set.  Provides descriptive labels for each column based on extract.

Finally, this aggregates the data based on Subject/Activity and determines the Mean of each column.  Used two approaches to aggregate function and sqldf to get same result.

Output:
- tidied.txt: Final aggregate using aggregate function
- sqlo.txt: Final aggregate from sqldf
- CodeBook.MD : Attempt to create basic CodeBook by looking at each column data 