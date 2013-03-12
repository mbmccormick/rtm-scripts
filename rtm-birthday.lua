-- number of days to look ahead
local LOOK_AHEAD = 7

-- determine if string ends with specified suffix
function endsWith(value, suffix)
	return #value >= #suffix and value:find(suffix, #value-#suffix+1, true) and true or false
end

-- parse month from timestamp
function parseMonth(value)
	return tonumber(value:sub(5, 6))
end

-- parse day from timestamp
function parseDay(value)
	return tonumber(value:sub(7, 8))
end

-- main execution thread
local response = http.request {
	url = 'http://ical2json.herokuapp.com/yourserver.com/path/to/your/calendar.ics'
}

local data = json.parse(response.content)

local lookAheadDate = os.time() + (LOOK_AHEAD * 60 * 60 * 24)

for key, value in pairs(data.VCALENDAR.VEVENT) do
	if endsWith(value.SUMMARY, '\'s Birthday') then
		local birthdayDate = os.time {
			year = os.date('%Y'),
			month = parseMonth(value.DTSTART),
			day = parseDay(value.DTSTART)
		}
		
		if os.date('%m', birthdayDate) == os.date('%m', lookAheadDate) and
		   os.date('%d', birthdayDate) == os.date('%d', lookAheadDate) then
			log(value.SUMMARY .. ' is on ' .. os.date('%m/%d', birthdayDate))
			
			email.send {
				server = 'SERVER_ADDRESS',
				username = 'USERNAME',
				password = 'PASSWORD',
				from = 'EMAIL_ADDRESS',
				to = 'RTM_EMAIL_ADDRESS',
				subject = value.SUMMARY .. ' ^' .. os.date('%m/%d', birthdayDate),
				text = ''
			}
		end
	end
end
