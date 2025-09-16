# SmsAero Ruby Api


### Installation:

```bash
gem install smsaero_api
```


### Usage:

```ruby
require 'smsaero_api'

SMSAERO_EMAIL = 'your email'
SMSAERO_API_KEY = 'your api key'

api = SmsAeroApi::SmsAero.new(SMSAERO_EMAIL, SMSAERO_API_KEY)

# Send SMS message
begin
  puts api.send('70000000000', 'Hello, World!')
rescue => e
  puts "Error: #{e.message}"
end

# Send Telegram code
begin
  result = api.send_telegram('70000000000', 1234, 'SMS Aero', 'Ваш код 1234')
  puts "Telegram sent: #{result}"
rescue => e
  puts "Error: #{e.message}"
end
```


### License

    MIT License
