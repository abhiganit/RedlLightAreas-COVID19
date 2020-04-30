import pandas as pd
from bokeh.plotting import figure, output_file, show
from bokeh.models import ColumnDataSource
from bokeh.models.tools import HoverTool
from bokeh.models import Select
from bokeh.io import curdoc
from bokeh.layouts import column



output_file('impact_of_rla.html')


# Load data
df = pd.read_excel('Population_distribution.xlsx')
# format it to use in bokeh
#source = ColumnDataSource(df)


# figure in bokeh
p = figure()

source = dict(x=df['Unnamed: 0'].values,y=df['India'].values)

p.circle('x','y' ,source=source,color='blue')


#p.legend.click_policy ='hide'

# hover = HoverTool()
# hover.tooltips = [('Population','@India'),
#                   ('Population in red light area','@India_RLA')]

# p.add_tools(hover)


menu = Select(options=['India','Mumbai','Kolkata'],value='India',title='Location')

def callback(attr, old, new):
    source.data={'x':df['Unnamed: 0'].values,'y':df[menu.value].values}



menu.on_change('value',callback)

layout = column(menu,p)

curdoc().add_root(layout)

show(layout)
