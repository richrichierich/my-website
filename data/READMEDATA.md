To acquire crime data, visit 
[the Toronto Police's Public Safety Data Portal](https://data.torontopolice.on.ca/datasets/0a239a5563a344a3bbf8452504ed8d68_0/explore),
and either download the full dataset or use an API call. To obtain the exact data
used in this study, use an API call with [this url](https://services.arcgis.com/S9th0jAJ7bqgIRjw/arcgis/rest/services/Major_Crime_Indicators_Open_Data/FeatureServer/0/query?where=OCC_YEAR%20%3D%20'2024'%20AND%20NEIGHBOURHOOD_158%20%3D%20'YONGE-BAY%20CORRIDOR%20(170)'&outFields=EVENT_UNIQUE_ID,OCC_YEAR,OCC_MONTH,OCC_DAY,OCC_HOUR,OFFENCE,MCI_CATEGORY,NEIGHBOURHOOD_158,LOCATION_TYPE&outSR=4326&f=json),
combined with an API call with [this url](https://services.arcgis.com/S9th0jAJ7bqgIRjw/arcgis/rest/services/Major_Crime_Indicators_Open_Data/FeatureServer/0/query?where=OCC_YEAR%20%3D%20'2024'%20AND%20NEIGHBOURHOOD_158%20%3D%20'DOWNTOWN%20YONGE%20EAST%20(168)'&outFields=EVENT_UNIQUE_ID,OCC_YEAR,OCC_MONTH,OCC_DAY,OCC_HOUR,OFFENCE,MCI_CATEGORY,NEIGHBOURHOOD_158,LOCATION_TYPE&outSR=4326&f=json).


To acquire meteorological data, visit [the Open Meteo API Homepage](https://open-meteo.com/en/docs).
To acquire the data used in this study, make an API call with [this url](https://historical-forecast-api.open-meteo.com/v1/forecast?latitude=43.7001&longitude=-79.4163&start_date=2024-01-01&end_date=2024-12-31&hourly=temperature_2m,relative_humidity_2m,dew_point_2m,precipitation,rain,showers,snowfall,snow_depth,visibility,wind_speed_10m&timezone=America%2FNew_York)