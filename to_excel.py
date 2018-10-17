import pandas as pd
import numpy as np
import sys
 
relFile = sys.argv[1]#'data/NPS_test_17_09_05.relrefstr.npz'
outFile = sys.argv[2]
 
df = pd.DataFrame(
    np.load(relFile)['pdframe'],
    index=np.load(relFile)['pdindex'],
    columns=np.load(relFile)['pdcolumns'])
 
writer = pd.ExcelWriter(outFile,engine='xlsxwriter')
df.to_excel(writer)
writer.save()		