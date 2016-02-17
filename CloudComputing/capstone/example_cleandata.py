#!/usr/bin/env python

import os,sys
import zipfile
import csv
#columnsIndex = [5,6,11,17,23,24,25,26,34,35,36,37]
columnsIndex = [5,6,10,11,17,23,25,34,36,47]
#5: FlightDate
#6: UniqueCarrier
#10: FlightNum
#11: Origin
#17: Dest
#23: CRSDepTime
#25: DepDelay
#26: DepDelayMinutes
#34: CRSArrTime
#36: ArrDelay
#37: ArrDelayMinutes 
#47: flights
def parseline( line ):
    splits = line.split(",")
    if len(splits) > 37:
        newline = ""
        for index in columnsIndex:
            newline += splits[index] + ","
            newline = newline[:-1]
            print newline

        
def parsecsvfile(csvfile,csvwriter):
    ifile  = open(csvfile, "rb")
    reader = csv.reader(ifile)
    rownum = 0
    for row in reader:
        # Save header row.
        if rownum == 0:
            header = row
        else:
            newRow = []
            badData = False
            for index in columnsIndex:
                if len(row[index].replace("\"",'').strip()) == 0:
                    badData = True
                else:
                    newRow.append(row[index])
            if not badData:
                csvwriter.writerow(newRow)    
        rownum += 1
    ifile.close()
    
    
def parsezipfile(filename):
    #unzip
    fh = open(filename, 'rb')
    z = zipfile.ZipFile(fh)
    for name in z.namelist():
        outpath = os.getcwd()
        z.extract(name, outpath)
        if name.lower().endswith(".csv"):
            print os.path.join(outpath,name)
            try:
                ofileName = os.path.join(outpath,"clean_" + name)
                ofile  = open(ofileName, "wb")
                csvwriter = csv.writer(ofile, delimiter=',', quotechar='"', quoting=csv.QUOTE_NONNUMERIC)
                parsecsvfile(os.path.join(outpath,name),csvwriter)
                print 'aws s3 cp %s s3://cloudcapsule.sixi/input/' %ofileName
                os.system('aws s3 cp %s s3://cloudcapsule.sixi/input/' %ofileName)                
            except Exception, err:
                print 'failed to parse : ', filename
                print err
            finally:
                ofile.close()
                os.remove(ofileName)
        os.remove(os.path.join(outpath,name))
    fh.close()

def parseFolders(rootdir):
    for subdir, dirs, files in os.walk(rootdir):
        for file in files:
            #print os.path.join(subdir, file)
            filepath = subdir + os.sep + file
            if filepath.endswith(".zip"):
                print (filepath)
                try:                
                    parsezipfile(filepath)
                except Exception, err:
                    print 'failed to parse : ', filepath
                    print err

                     
def main(rootdir):
    #ofile  = open('cleandata2.csv', "wb")
    #csvwriter = csv.writer(ofile, delimiter=',', quotechar='"', quoting=csv.QUOTE_NONNUMERIC)
    parseFolders(rootdir)
    #ofile.close()

if __name__=='__main__':
    # Example usage
    if len(sys.argv) < 2:
        print 'usage: cleandata.py folder'
        sys.exit(1)
    main(sys.argv[1])
    