# -*- coding: utf-8 -*-
import dash
import dash_html_components as html
import dash_core_components as dcc
import base64
import dash_table as dt
import pandas as pd
import plotly.graph_objs as go


from dash.dependencies import Input, Output

external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']

data_risk=[['18 Degrees','Betting'],['Hacienda"s Mexican Grill','Fair'],
['La Locanda Ristorante Italiano','Fair'],['Los Betos Mexican Food','Fair'],
['Mint Indian Cuisine','Betting'],['Nonna Urban Eatery','Fair'],
['Red Kimchi Korean Restaurant','Fair'],['Relish Burger Bistro','Betting'],
['Starbucks','No Touch'],['Tokyo Joe"s','Betting']]



df=pd.DataFrame(data_risk, columns = ['Name','Risk Profile']) 

df_checkins=pd.read_csv('checkins.csv')
df_checkins['Date'] = pd.to_datetime(df_checkins.month_year, infer_datetime_format=True)

available_indicators = df_checkins['Name'].unique()

df_clusters=pd.read_csv('df_clusters.csv') 

def generate_table(dataframe, max_rows=10):
    return html.Table(
        # Header
        [html.Tr([html.Th(col) for col in dataframe.columns])] +

        # Body
        [html.Tr([
            html.Td(dataframe.iloc[i][col]) for col in dataframe.columns
        ]) for i in range(min(len(dataframe), max_rows))]
    )

image_filename = 'yelp.png' # replace with your own image
encoded_image = base64.b64encode(open(image_filename, 'rb').read())


app = dash.Dash(__name__, external_stylesheets=external_stylesheets)
app.layout = html.Div([
    html.Img(src='data:image/png;base64,{}'.format(encoded_image)),
    html.Div(id='profile_container', style={"border":"1px black solid"}),
    html.Div(children=[
        html.H4(children='Risk Profile', ),
        dcc.Dropdown(id='dropdown', options=[
        {'label': i, 'value': i} for i in df.Name.unique()], multi=False, placeholder='Filter by business...'),
    html.Div(id='table-container')
]),
  html.Div([
    html.H4(children='Check Ins',),
    dcc.Dropdown(id='graph-dropdown',
    options=[{'label': '18 Degrees', 'value': '18 Degrees'},
             {'label': 'Haciendas Mexican Grill', 'value': 'Haciendas Mexican Grill'},
             {'label': 'La Locanda Ristorante Italiano', 'value': 'La Locanda Ristorante Italiano'},
             {'label': 'Los Betos Mexican Food', 'value': 'Los Betos Mexican Food'},
             {'label': 'Mint Indian Cuisine', 'value': 'Mint Indian Cuisine'},
             {'label': 'Nonna Urban Eatery', 'value': 'Nonna Urban Eatery'},
             {'label': 'Red Kimchi Korean Restaurant', 'value': 'Red Kimchi Korean Restaurant'},
             {'label': 'Relish Burger Bistro', 'value': 'Relish Burger Bistro'},
             {'label': 'Starbucks', 'value': 'Starbucks'},
             {'label': 'Tokyo Joes', 'value': 'Tokyo Joes'}
    
    ],
        multi=False,style={"display": "block","margin-left":0,"margin-right": "auto","width": "60%"}),
    dcc.Graph(id='my-graph')
], className="container"),  
    html.Div(children=[
        html.H4(children='Cluster Profile', ),
        dcc.Dropdown(id='dropdown2', options=[
        {'label': i, 'value': i} for i in df_clusters.Name.unique()], multi=False, placeholder='Filter by business...'),
    html.Div(id='table-container2')
    ]),
    # html.Div([
    # dcc.Dropdown(
    #     id='demo-dropdown',
    #     options=[
    #         {'label': '18 Degrees', 'value': '47% Cluster 10, 27% Cluster 17 - Mediocre, with the common phrase "Waste of Time"'},
    #         {'label': 'Hacienda"s Mexican Grill', 'value': '35% Cluster 0, 30% Cluster 10 - Very mixed reviews, only slightly more positive than negative'},
    #         {'label': 'La Locanda Ristorante Italiano', 'value': '58% Cluster 0, 18% Cluster 17 - Great food and service, with a small portion of luke-warm reviews'},
    #         {'label': 'Los Betos Mexican Food', 'value': '38% Cluster 0, 30% Cluster 17 - Slightly more positive than neutral'},
    #         {'label': 'Mint Indian Cuisine', 'value': '45% Cluster 10 and 35% Cluster 0 - More negative than positive, but very mixed review set'},
    #         {'label': 'Nonna Urban Eatery', 'value': '59% Cluster 0, 20% Cluster 10 - Mixed reviews that skew much more towards Great food and service'},
    #         {'label': 'Red Kimchi Korean Restaurant', 'value': '36% Cluster 10, 33% Cluster 1- Great food and service mixed with waste of time and sizeable luke-warm reviews'},
    #         {'label': 'Relish Burger Bistro', 'value': '40% Cluster 0, 24% Cluster 17- overall positive with some improvements needed to food or service'},
    #         {'label': 'Starbucks', 'value': '64% Cluster 10, 15% Cluster 17 - deeply disliked, luke warm at best.  "Waste of Money"'},
    #         {'label': 'Tokyo Joe"s', 'value': '43% Cluster 10, 32% Cluster 0 - Mixed reviews, split between good food and service, and waste of time'}
    #     ],
    #     value='Nothing yet!'
    # ),
    html.Div(id='datatable-filter-container'),  
    html.Div(id='dd-output-container')
             
])

   
@app.callback(
    dash.dependencies.Output('table-container', 'children'),
    [dash.dependencies.Input('dropdown', 'value')])
def display_table(dropdown_value):
    if dropdown_value is None:
        return ''

    dff = df[df.Name.str.contains((dropdown_value))]
    return generate_table(dff)


@app.callback(Output('my-graph', 'figure'), 
        [Input('graph-dropdown', 'value')])
def update_graph(graph_dropdown_value):
    dropdown = {'Haciendas Mexican Grill','La Locanda Ristorante Italiano','Los Betos Mexican Food','Mint Indian Cuisine',
                 'Nonna Urban Eatery','Red Kimchi Korean Restaurant','Relish Burger Bistro','Starbucks','Tokyo Joes'}
    df2 = df_checkins[df_checkins['Name'] == graph_dropdown_value]
    return {
        'data': [{
            'x': df2.Date,
            'y': df2.biz_checkin
        }],
        'layout': {'margin': {'l': 40, 'r': 0, 't': 20, 'b': 30}}
    }


@app.callback(
    dash.dependencies.Output('table-container2', 'children'),
    [dash.dependencies.Input('dropdown2', 'value')])
def display_table(dropdown_value2):
    if dropdown_value2 is None:
        return ''

    dff3 = df_clusters[df_clusters.Name.str.contains((dropdown_value2))]
    return generate_table(dff3)



if __name__ == '__main__':
    app.run_server(debug=True)
