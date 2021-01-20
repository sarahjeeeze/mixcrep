import pandas as pd
import sys


#find all sequences

originalInput = str(sys.argv[1])
originalOutput = str(sys.argv[2])

def readInput():
    a = open(str(originalInput))

    a = a.readlines()
    firstParse = (a[::2])
    secondParse = []
    for i in firstParse:
        secondParse.append(i.strip().strip('>'))
    return secondParse

def readOutput():
    output = pd.read_csv(str(originalOutput), sep='\t')
    outputDescriptions = list(output['descrsR1'])
    return outputDescriptions

count = 0
listOne = readInput()
listTwo = readOutput()
#find out which ones dont exist in datatable as rejected
notInOutput = []
for i in listOne:
    if i in listTwo:
        count += 1
    else:
        notInOutput.append(i)

#rename existing columns
df = pd.read_csv(str(originalOutput), sep='\t')
df2 = df.rename({'descrsR1': 'sequence_id', 'bestVHit': 'v_call','bestDHit':'d_call','bestJHit':'j_call','aaSeqCDR3':'cdr3_aa'}, axis=1)

df2['productive'] = 'true'


df3= pd.DataFrame(notInOutput, columns=['sequence_id'])
df3['productive'] = 'false'

df4 = df2.append(df3)


df4.to_csv('finalMixcrep.tsv', sep = '\t', index=False)
