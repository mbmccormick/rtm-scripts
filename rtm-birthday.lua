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

-- fetch calendar data, if not already cached
if storage.calendar == nil then
	local response = http.request {
		url = 'http://ical2json.herokuapp.com/yourserver.com/path/to/your/calendar.ics'
	}
	
	storage.calendar = response.content
end

-- parse calendar data
local data = json.parse(storage.calendar)

local lookAheadDate = os.time() + (LOOK_AHEAD * 60 * 60 * 24)

-- extract birthdays from calendar data
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
			
			-- create task in Remember The Milk via email
			email.send {
				server = 'SERVER_ADDRESS',
				username = 'USERNAME',
				password = 'PASSWORD',
				from = 'EMAIL_ADDRESS',
				to = 'RTM_EMAIL_ADDRESS',
				subject = value.SUMMARY .. ' ^' .. os.date('%m/%d', birthdayDate) .. ' !',
				text = ''
			}
		end
	end
end
