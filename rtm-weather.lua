local lom = require 'lxp.lom'
local xpath = require 'xpath'

local hour = tonumber(os.date('%H')) - 7

-- only run at 11:00pm pacific time
if (hour ~= 23) then
	return
end

-- fetch latest weather for Seattle, WA
local response = http.request {
	url = 'http://weather.yahooapis.com/forecastrss?w=12798953'
}

-- parse weather forecast
local forecast = xpath.selectNodes(lom.parse(response.content), '//yweather:forecast')[1]

-- we only care about precipitation
if forecast.attr.code == '0' or -- tornado
   forecast.attr.code == '1' or -- tropical storm
   forecast.attr.code == '2' or -- hurricane
   forecast.attr.code == '3' or -- severe thunderstorms
   forecast.attr.code == '4' or -- thunderstorms
   forecast.attr.code == '5' or -- mixed rain and snow
   forecast.attr.code == '6' or -- mixed rain and sleet
   forecast.attr.code == '7' or -- mixed snow and sleet
   forecast.attr.code == '8' or -- freezing drizzle
   forecast.attr.code == '9' or -- drizzle
   forecast.attr.code == '10' or -- freezing rain
   forecast.attr.code == '11' or -- showers
   forecast.attr.code == '12' or -- showers
   forecast.attr.code == '17' or -- hail
   forecast.attr.code == '18' or -- sleet
   forecast.attr.code == '35' or -- mixed rain and hail
   forecast.attr.code == '37' or -- isolated thunderstorms
   forecast.attr.code == '38' or -- scattered thunderstorms
   forecast.attr.code == '39' or -- scattered thunderstorms
   forecast.attr.code == '40' or -- scattered showers
   forecast.attr.code == '45' or -- thundershowers
   forecast.attr.code == '47' then -- isolated thundershowers
	
	local body = string.format('The forecast for today calls for %s with a high of %d degrees and a low of %d degrees.', forecast.attr.text:lower(), forecast.attr.high, forecast.attr.low)
	
	-- create task in Remember The Milk via email
	email.send {
		server = 'SERVER_ADDRESS',
		username = 'USERNAME',
		password = 'PASSWORD',
		from = 'EMAIL_ADDRESS',
		to = 'RTM_EMAIL_ADDRESS',
		subject = 'Bring an umbrella ^tomorrow at 9am',
		text = 'Forecast\n' .. body
	}
	
	log('Forecast for tomorrow calls for precipitation. Message sent.')
else
	log('Forecast for tomorrow does not call for precipitation.')
end
