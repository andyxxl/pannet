#!/usr/bin/python
# predchadzajuci riadok musi obsahovat kazdy program aby bol spustitelny
# v Python. Hovori shellu, ako ma spustit program - teda pomocou /usr/bin/python

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

# import balicek pyowm. Musis ho najskor nainstalovat do systemu, aby si ho mohol
# importovat.
# PyOWM is a client Python wrapper library for OpenWeatherMap web APIs. 
# It allows quick and easy consumption of OWM data from Python applications
# via a simple object model and in a human-friendly fashion.
# OpenWeatherMap je web API pe pocasie https://openweathermap.org
import pyowm

#----- VARIABLES ---------
# co premennej CITY_NAME priradis retazec 'Bratislava,SK'
# to iste pre premennu OPENWEATHER_API_KEY
# retazce sa ohranicene jednoduchymi uvodzovkami
CITY_NAME           = 'Bratislava,SK'
OPENWEATHER_API_KEY = '0b70d07a0a04c8559750aac0b90d2a79'

#----- FUNCTIONS ---------
# funkcia get_weather vrati naplneny dictionary (alebo slovnik, hash, mapu))
# datami. TEda napr. slovnikovej premennej meteo_dict['temp'] sa priradi 
# odcitana aktualna teplota a atd pre kazdu premennu slovnika
def get_weather():
   # dictionary (hash) with default weather parameters
   # na zaciatku si vytvorim slovnik s premennimi pocasia, ktore chcem sledovat
   # a priradim im default 0-ove hodnoty
   meteo_dict = {'wind_deg':0, 'wind_speed':0, 'status':0, 'humidity': 0, 'temp':0, 'temp_min':0, 'temp_max':0, 'pressure':0}

   # use OWM key
   # Example of using API key in API call
   # Description:
   # Please, use your API key in each API call.
   # We do not process API requests without the API key.
   # API call:
   # http://api.openweathermap.org/data/2.5/forecast?id=524901&APPID={APIKEY}
   # Parameters:
   # APPID {APIKEY} is your unique API key
   # Example of API call:
   # api.openweathermap.org/data/2.5/forecast?id=524901&APPID=1111111111
   owm = pyowm.OWM(OPENWEATHER_API_KEY)

   # set location
   # na ziaciatku si do CITY_NAME ulozil hodnotu Bratislava,SK
   # a teda do premennej location ulozis lokalitu kde sa nachadzas
   # Do location sa ulozi vystup z funkcie owm.weather_at_place()
   # parameter funkcie je premenna  CITY_NAME
   location = owm.weather_at_place(CITY_NAME)

   # request weather info from OWM API
   # finkcia zisti pocasie a ulozi do premennej w
   w = location.get_weather()

   # partial weather parameters
   # volania jednotlivych funkcii vratia a teda priradia do premennych 
   # temp, pressure a wind dane hodnoty. NIe su to len ciste hodnoty 
   # moze to byt aj struktura ako temp to je dalsia dictionary struktura
   # ktora obsajuje min, max a aktualnu teplotu
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
# tu v skutocnosti zacina program 
# ktory najskor vola funkciu get_weather, ktora vypluje do premennej
# meteo_dict strukturu s datami o pocasi. 
# nasledne sa vola druha funkcia print_me ta ma za parameter strukturu
# meteo_dict a vypise udaje
meteo_dict = get_weather()
print_me(meteo_dict)

