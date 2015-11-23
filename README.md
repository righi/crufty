# Crufty

Don't let quick fixes turn into permanently crufty code. Give it an expiration date.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'crufty'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install crufty

## Usage

```ruby
WARN_AFTER =  DateTime.parse("2015-12-15 10:00AM -800")
ERROR_AFTER = DateTime.parse("2015-12-20 10:00AM -800")

# TODO: Remove this code before it starts to spit out warnings, 
# and DEFINITELY remove it before it starts raising errors.
crufty(WARN_AFTER, ERROR_AFTER) do
  # Hacky code goes here
end

# If you just want the warnings and never want it to error:

crufty(WARN_AFTER) do
  # Hacky code goes here
end


# Explicit Usage:

crufty(best_by: WARN_AFTER, expires: ERROR_AFTER) do
  # Hacky code goes here
end


```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/righi/crufty. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

