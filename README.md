# Roda::Monads

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'roda-monads'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install roda-monads

## Usage

```ruby
require 'bundler/inline'

gemfile do
  gem 'rspec'
  gem 'roda-monads'
end

class App < Roda
  plugin :endpoints

  route do |r|
    r.on 'value' do
      Right('Alright')
    end
    r.on 'status' do
      Left(:unauthorized)
    end
    r.on 'rack' do
      r.on 'symbol' do
        r.on 'right' do
          Right([:ok, {}, 'OK'])
        end
        r.on 'left' do
          Left([:found, { 'Location' => '/rack_right' }, nil])
        end
      end
      r.on 'right' do
        Right([200, {}, 'OK'])
      end
      r.on 'left' do
        Left([:unauthorized, {}, nil])
      end
    end
    r.on 'neither' do
      'neither'
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bin/rake install`. To release a new version, update the version number in `version.rb`, and then run `bin/rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://gitlab.com/alsemyonov/roda-monads. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


© [Alex Semyonov](https://alex.semyonov.us/), <[alex@semyonov.us](mailto:alex@semyonov.us?subject=roda-monads)> 2017
