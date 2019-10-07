#!/usr/bin/python

# ZADANIE:
# Create a simple python script getweather.py with the following specs:
# - Retrieves weather data from https://openweathermap.org/api
# - It uses the current weather data API: https://openweathermap.org/current
# - It uses pyown: https://pypi.python.org/pypi/pyowm
# - The python script uses no arguments, only the following environment variables:
#    OPENWEATHER_API_KEY
#    CITY_NAME
#
# - It outputs to stdout
#
# OWM_KEY registered for andrej.krnac@gmail.com: 0b70d07a0a04c8559750aac0b90d2a79

import pyowm

#----- VARIABLES ---------
CITY_NAME           = 'Bratislava,SK'
OPENWEATHER_API_KEY = '0b70d07a0a04c8559750aac0b90d2a79'

#----- FUNCTIONS ---------
def get_weather():
   # dictionary (hash) with default weather parameters
   meteo_dict = {'wind_deg':0, 'wind_speed':0, 'status':0, 'humidity': 0, 'temp':0, 'temp_min':0, 'temp_max':0, 'pressure':0}

   # use OWM key
   owm = pyowm.OWM(OPENWEATHER_API_KEY)
   # set location
   location = owm.weather_at_place(CITY_NAME)

   # request weather info from OWM API
   w = location.get_weather()

   # partial weather parameters
   temp     = w.get_temperature('celsius')
   pressure = w.get_pressure()
   wind     = w.get_wind()

   # save weather parameters to meteo_dict
   meteo_dict['humidity']   = w.get_humidity()
   meteo_dict['temp']       = temp['temp']
   meteo_dict['temp_min']   = temp['temp_min']
   meteo_dict['temp_max']   = temp['temp_max']
   meteo_dict['pressure']   = pressure['press']
   meteo_dict['wind_deg']   = wind['deg']
   meteo_dict['wind_speed'] = wind['speed']
   meteo_dict['status']     = w.get_detailed_status()

   return meteo_dict


# print weather info on screen
def print_me(meteo_dict):
   print("Temperature: %s C, Min Temp: %s C, Max Temp: %s C " % (meteo_dict['temp'], meteo_dict['temp_min'], meteo_dict['temp_max']))
   print("Pressure: %s Millibars" % meteo_dict['pressure'])
   print("Humidity: %s %%rH" % meteo_dict['humidity'])
   print("Wind direction: %s deg, Wind speed: %s m/s" % (meteo_dict['wind_deg'], meteo_dict['wind_speed']))
   print("Weather status: %s" % meteo_dict['status'])



# ----------- MAIN PROGRAMM --------
meteo_dict = get_weather()
print_me(meteo_dict)

