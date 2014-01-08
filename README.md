# Felis
Felis is an API wrapper for [Emma's API](http://api.myemma.com/index.html)

## Requirements
[MyEmma](http://myemma.com/) account and API credentials (private & public key)

## Usage

## Instantiation
```ruby
require 'felis'
felis = Felis::API.new(account_id: 'ACCOUNT_ID', public_key: 'PUBLIC_KEY', private_key: 'PRIVATE_KEY')
```

You can also set environment variables and Felis will use them when you create an instance
```ruby
ENV['EMMA_ACCOUNT_ID'] = 'account_id'
ENV['EMMA_PUBLIC_KEY'] = 'public_key'
ENV['EMMA_PRIVATE_KEY'] = 'private_key'
felis = Felis::API.new
```

## GET Request
```ruby
# Returns array of members
request = felis.get '/members'
puts request.inspect
```

## POST Request
```ruby
# Will return a reference object of the newly added member
request = felis.post '/members/add', {"email" => "test@example.com", fields: {first_name: "Jack", last_name: "Jill"}}
puts request.inspect
```

## PUT Request
```ruby
# Returns true on success
request = felis.put '/members/123', { fields: { first_name: "Jane" } }
puts request.inspect
```

## DELETE Request
```ruby
# Returns true on success
request = felis.delete '/members/123'
puts request.inspect
```

## Installation

Add this line to your application's Gemfile:

    gem 'felis'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install felis

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
