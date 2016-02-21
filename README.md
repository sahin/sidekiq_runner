# Sidekiq Runner

This gem provides easily run multiple methods per sidekiq worker

## Installing

```ruby
gem 'sidekiq-runner'
```

### Example
```ruby
# Your worker
class UrlShortenerWorker
  include Sidekiq::Worker
  sidekiq_options backtrace: true, queue: 'url_shortener', retry: 2

  def create_from_google(params)
    # id = params[:id]
    # Video.find(id)
    # Do something here
  end
  
  def create_from_bitly(params)
    # id = params[:id]
    # Video.find(id)
    # Do something here
  end
  
  def my_other_method
    # Do something here
  end
end
```


Run `create_from_google` method

```ruby
SidekiqRunner::Run.enqueue('UrlShortenerWorker', 'create_from_google', { id: 1, my_other_arg: 2 })
# or
SidekiqRunner::Run.run('UrlShortenerWorker', 'create_from_google', { id: 1, my_other_arg: 2 })
```

Run `create_from_bitly` method

```ruby
SidekiqRunner::Run.enqueue('UrlShortenerWorker', 'create_from_bitly', { id: 1, my_other_arg: 2 })
# or
SidekiqRunner::Run.run('UrlShortenerWorker', 'create_from_bitly', { id: 1, my_other_arg: 2 })
```

Run `my_other_method` method

```ruby
SidekiqRunner::Run.enqueue('UrlShortenerWorker', 'my_other_method')
# or
SidekiqRunner::Run.run('UrlShortenerWorker', 'my_other_method')
```

#### NOTE

`enqueue` method gets queue from `sidekiq_options`

#### Difference `enqueue` & `run`

`run` method runs job instantly in without production environments, sends job to queue only in production. `enqueue` method  sends job to queue in all environments

## Running Tests

    $ bundle install
    $ bundle exec rake test

If you need to test against local gems, use Bundler's gem :path option in the Gemfile and also edit `test/support/test_helper.rb` and tell the tests where the gem is checked out.

## Code Status

* [![Travis CI]()]()
* [![Gem Version]()]()
* [![Dependencies]()]()
