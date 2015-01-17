# Jekyll::Compose

Streamline your writing in Jekyll with some commands.

[![Build Status](https://travis-ci.org/jekyll/jekyll-compose.svg?branch=master)](https://travis-ci.org/jekyll/jekyll-compose)

## Installation

Add this line to your application's Gemfile:

    gem 'jekyll-compose'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jekyll-compose

## Usage

Install `jekyll-compose` and run `jekyll help`.

Listed in help you will see new commands available to you:

```sh
  draft                 Creates a new draft post with the given NAME
  post                  Creates a new post with the given NAME
  publish               Moves a draft into the _posts directory and sets the date
```

Create your new post using:

    $ jekyll post "My New Post"

## Helpful Note

If after installing the jekyll-compose gem you still do not see the above commands avaiable to you, try including the gem in the jekyll_plugins group of your Gemfile like so:

```ruby
group :jekyll_plugins do
  gem 'jekyll-compose'
end
```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/jekyll-compose/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
