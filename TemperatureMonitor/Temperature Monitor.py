
# coding: utf-8

# # Make HTML and PNG

# In[14]:


import pandas as pd
import time;  # This is required to include time module.
import datetime
import optparse


# In[2]:


import utils


# In[12]:


VERSION=1.0
usage='TemperatureMonitor.py [-f temp.csv]'
epilog=''


# In[6]:


def SelectDataAndPlot(df,cols=None,dateField='Date',days=7,output_format='png'):
    """ Select a range of days starting `days` ago from its first positional argument"""
    if cols is not None:
        dt_now = datetime.datetime.now()
        beginning = dt_now - datetime.timedelta(days=days)
        data = df[cols][df[dateField]>beginning]
        utils.makeDateSeriesPlot(data,output_format=output_format,file_name_root=str(days))
    else:
        print('cols cannot be None')


# In[ ]:


def main():    
    parser = optparse.OptionParser(usage=usage, version=VERSION,epilog=epilog)
    parser.add_option('-f', '--file',action='store',default='temp.csv',help="CSV file to process")
    parser.add_option('-d', '--days',action='store',default=365,type=int,help="number of days to plot")
    options, args = parser.parse_args()
    days=options.days
    fileCSV=options.file
    ##########################################
    df=pd.read_csv(fileCSV)
    df.columns=['Epoch','Temperature','Humidity']
    df['Date']=(pd.to_datetime(df['Epoch'],unit='s'))
    ##########################################
    SelectDataAndPlot(df,cols=['Date','Temperature'],days=days)


# In[ ]:


if __name__ == "__main__":
    main()

