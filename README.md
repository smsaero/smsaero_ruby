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

begin
  puts api.send('70000000000', 'Hello, World!')
rescue => e
  puts "Error: #{e.message}"
end
```


### License

    MIT License
