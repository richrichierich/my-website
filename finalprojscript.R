library(httr)
library(jsonlite)
library(dplyr)
crime <- content(GET("https://services.arcgis.com/S9th0jAJ7bqgIRjw/arcgis/rest/services/Major_Crime_Indicators_Open_Data/FeatureServer/0/query?where=OCC_YEAR%20%3D%20'2024'%20AND%20NEIGHBOURHOOD_158%20%3D%20'YONGE-BAY%20CORRIDOR%20(170)'&outFields=EVENT_UNIQUE_ID,OCC_YEAR,OCC_MONTH,OCC_DAY,OCC_HOUR,OFFENCE,MCI_CATEGORY,NEIGHBOURHOOD_158,LOCATION_TYPE&outSR=4326&f=json"), "text", encoding = "UTF-8")


crime_data_cor <- fromJSON(crime)

crime_data_cor <- crime_data_cor$features$attributes

crime2 <- content(GET("https://services.arcgis.com/S9th0jAJ7bqgIRjw/arcgis/rest/services/Major_Crime_Indicators_Open_Data/FeatureServer/0/query?where=OCC_YEAR%20%3D%20'2024'%20AND%20NEIGHBOURHOOD_158%20%3D%20'DOWNTOWN%20YONGE%20EAST%20(168)'&outFields=EVENT_UNIQUE_ID,OCC_YEAR,OCC_MONTH,OCC_DAY,OCC_HOUR,OFFENCE,MCI_CATEGORY,NEIGHBOURHOOD_158,LOCATION_TYPE&outSR=4326&f=json"), "text", encoding = "UTF-8")

crime_data_y <- fromJSON(crime2)

crime_data_y <- crime_data_y$features$attributes

crime_data <- rbind(crime_data_y, crime_data_cor)
weather <- content(GET('https://historical-forecast-api.open-meteo.com/v1/forecast?latitude=43.7001&longitude=-79.4163&start_date=2024-01-01&end_date=2024-12-31&hourly=temperature_2m,relative_humidity_2m,dew_point_2m,precipitation,rain,showers,snowfall,snow_depth,visibility,wind_speed_10m&timezone=America%2FNew_York'), "text", encoding = "UTF-8")

weather_data <- fromJSON(weather)

weather_data <- data.frame(weather_data)

weather_data_clean <- weather_data %>% select(
  datetime = hourly.time,
  temperature = hourly.temperature_2m,
  humidity = hourly.relative_humidity_2m,
  dew_point = hourly.dew_point_2m,
  precipitation = hourly.precipitation,
  rain = hourly.rain,
  showers = hourly.showers,
  snowfall = hourly.snowfall,
  snow_depth = hourly.snow_depth,
  visibility = hourly.visibility,
  windsp = hourly.wind_speed_10m
  
  
)
library(lubridate)

crime_data$OCC_MONTH <- match(crime_data$OCC_MONTH, month.name)


crime_data$date <- make_datetime(
  year = as.integer(crime_data$OCC_YEAR), 
  month = as.integer(crime_data$OCC_MONTH), 
  day = as.integer(crime_data$OCC_DAY), 
  hour = as.integer(crime_data$OCC_HOUR)
)

weather_data_clean$datetime <- ymd_hm(weather_data_clean$datetime)

library(dplyr)

# Ensure both datetime columns are POSIXct
crime_data$OCC_DATETIME <- as.POSIXct(crime_data$date, tz = "UTC")
weather_data_clean$datetime <- as.POSIXct(weather_data_clean$datetime, tz = "UTC")

# Perform the join (inner join keeps only matching records)
merged_data <- crime_data %>%
  inner_join(weather_data_clean, by = c("date" = "datetime"))


merged_data <- merged_data %>%
  select(
    id = EVENT_UNIQUE_ID,
    location_type = LOCATION_TYPE,
    offence = OFFENCE,
    category = MCI_CATEGORY,
    neighborhood = NEIGHBOURHOOD_158,
    datetime = date,
    temperature = temperature,
    humidity = humidity,
    dew_point = dew_point,
    precipitation = precipitation,
    rain = rain,
    showers = showers,
    snowfall = snowfall,
    snow_depth = snow_depth,
    visibility = visibility,
    windsp = windsp
  ) %>%
  mutate(
    location_type = as.factor(location_type),
    offence = as.factor(offence),
    category = as.factor(category),
    neighborhood = as.factor(neighborhood)
  )

library(dplyr)
library(lubridate)

# Convert datetime columns to Date type and extract year-month for both datasets
weather_data_clean <- weather_data_clean %>%
  mutate(       # Ensure datetime is in the correct format
    month = floor_date(datetime, "month"))  # Extract the month-year

merged_data <- merged_data %>%
  mutate(      # Ensure datetime is in the correct format
    month = floor_date(datetime, "month"))  # Extract the month-year

# Group by month and calculate the average temperature for weather_data_clean
avg_temp_by_month <- weather_data_clean %>%
  group_by(month) %>%
  summarise(avg_temp = mean(temperature, na.rm = TRUE))  # Replace 'temperature' with the actual column name for temp

# Group by month and count the number of crimes in merged_data
crimes_by_month <- merged_data %>%
  group_by(month) %>%
  summarise(num_crimes = n())
# Convert datetime columns to Date type and extract year-month for both datasets
weather_data_clean <- weather_data_clean %>%
  mutate(       # Ensure datetime is in the correct format
    month = floor_date(datetime, "month"))  # Extract the month-year

merged_data <- merged_data %>%
  mutate(      # Ensure datetime is in the correct format
    month = floor_date(datetime, "month"))  # Extract the month-year

# Group by month and calculate the average temperature for weather_data_clean
avg_temp_by_month <- weather_data_clean %>%
  group_by(month) %>%
  summarise(avg_temp = mean(temperature, na.rm = TRUE))  # Replace 'temperature' with the actual column name for temp

# Group by month and count the number of crimes in merged_data
crimes_by_month <- merged_data %>%
  group_by(month) %>%
  summarise(num_crimes = n())

# Merge the two data frames by month
final_table <- left_join(avg_temp_by_month, crimes_by_month, by = "month")

# Format the month column to display full month names
final_table <- final_table %>%
  mutate(month = format(month, "%B"))

library(dplyr)
library(lubridate)
library(mgcv)
library(randomForest)
library(xgboost)
library(Metrics)
library(ggplot2)

# Prepare data with seasonal features and aggregate
model_data <- merged_data %>%
  group_by(datetime) %>%
  summarise(
    crime_count = n(),
    datetime = first(datetime)
  ) %>%
  ungroup()

model_data2 <- model_data %>% right_join(weather_data_clean, by = c("datetime" = "datetime"))

model_data_grouped <- model_data2 %>% mutate(date = as.Date(datetime),
                                             dateint = as.numeric(difftime(date, min(date), units = "days")),
                                             hour = hour(datetime),
                                             month = (month(datetime))
)

model_data_grouped[is.na(model_data_grouped)] <- 0

set.seed(42)
split <- sample(1:nrow(model_data_grouped), size = 0.8 * nrow(model_data_grouped))
train <- model_data_grouped[split, ]
test <- model_data_grouped[-split, ]

# === Random Forest ===
rf_model <- randomForest(
  crime_count ~ temperature + humidity + precipitation + snowfall +
    windsp + visibility,
  data = train,
  ntree = 500,
  importance = TRUE
)

rf_preds <- predict(rf_model, newdata = test)
rmse_rf <- rmse(test$crime_count, rf_preds)

# === XGBoost ===
x_train <- as.matrix(train %>% select(-crime_count, -datetime, -date, -hour, -dateint, -month, -snow_depth, -rain))
x_test <- as.matrix(test %>% select(-crime_count, -datetime, -date, -hour, -dateint, -month, -snow_depth, -rain))
y_train <- train$crime_count
y_test <- test$crime_count

xgb_model <- xgboost(
  data = x_train,
  label = y_train,
  nrounds = 100,
  objective = "count:poisson",
  verbose = 0
)

xgb_preds <- predict(xgb_model, newdata = x_test)
rmse_xgb <- rmse(y_test, xgb_preds)
