
# coding: utf-8

# In[64]:


import pandas as pd
import matplotlib.pyplot as plt
from bokeh.io import show, output_file, save
from bokeh.layouts import column
from bokeh.models import ColumnDataSource, RangeTool
from bokeh.plotting import figure
import time;  # This is required to include time module.
import datetime


# In[15]:


df=pd.read_csv('temp.csv')


# In[22]:


df.columns=['Epoch','Temperature','Humidity']


# In[37]:


df['Date']=(pd.to_datetime(df['Epoch'],unit='s')) 


# In[60]:


dt_now = datetime.datetime.now()
yesterday = dt_now - datetime.timedelta(days=1)


# In[61]:


data = df[['Date','Temperature']][df['Date']>yesterday]


# In[66]:


p = figure(plot_height=300, plot_width=800, tools="xpan", toolbar_location=None,
           x_axis_type="datetime", x_axis_location="above",
           background_fill_color="#efefef", x_range=(data['Date'].min(), data['Date'].max()))

p.line('Date', 'Temperature', source=data)
p.yaxis.axis_label = 'Temperature [C]'

select = figure(title="Drag the middle and edges of the selection box to change the range above",
                plot_height=130, plot_width=800, y_range=p.y_range,
                x_axis_type="datetime", y_axis_type=None,
                tools="", toolbar_location=None, background_fill_color="#efefef")

range_tool = RangeTool(x_range=p.x_range)
range_tool.overlay.fill_color = "navy"
range_tool.overlay.fill_alpha = 0.2

select.line('Date', 'Temperature', source=data)
select.ygrid.grid_line_color = None
select.add_tools(range_tool)
select.toolbar.active_multi = range_tool

#show(column(p, select))
output_file("temp.html")
save(column(p, select))

