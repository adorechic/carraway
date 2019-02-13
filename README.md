# Carraway [![Build Status](https://travis-ci.org/adorechic/carraway.svg?branch=master)](https://travis-ci.org/adorechic/carraway) [![Maintainability](https://api.codeclimate.com/v1/badges/0c6800daedd07274f11c/maintainability)](https://codeclimate.com/github/adorechic/carraway/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/0c6800daedd07274f11c/test_coverage)](https://codeclimate.com/github/adorechic/carraway/test_coverage)

Carraway is a lightweight CMS backend for [Gatsby](https://www.gatsbyjs.org/).

Carraway provides
- Web console to edit contents
- Web preview for contents on Gatsby
- REST API for Gatsby to integrate with Carraway

[gatsby-source-carraway](https://github.com/adorechic/gatsby-source-carraway) is a source plugin for Gatsby to integrate with Carraway.

Carraway is required on Gatsby build and contents editting, so you don't have to keep running Carraway process.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'carraway'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install carraway

## Usage
Put carraway.yml

```yaml
backend:
  table_name: 'carraway_table' # If you use DynamoDB Local, set endpoint option
file_backend:
  bucket: 'carraway_bucket'
  prefix: 'files'
categories:
  category_key:
    title: 'Category Name'
    dir: '/category/path'
```

Create DynamoDB table.

```
carraway setup

# You can use different config file name
# carrway setup -c your_config.yml
```

Run carrway

```
carraway start
```

## Configuration

```yaml
port: 5000 # Optional. Defailt port is 5000
gatsby_endpoint: 'http://localhost:8000' # Optional. Default is http://localhost:8000
backend: # Required
  table_name: 'carraway_table' # Required.
  endpoint: http://localhost:6000 # Optional. Set if you use DynamoDB Local
  region: ap-northeast-1 # Optional.
file_backend:
  bucket: 'carraway_bucket' # Required
  prefix: 'files' # Required.
  endpoint: http://localhost:6001 # Optional. Set if you use local S3 like mineo
  region: ap-northeast-1 # Optional.
categories: # Least one category is required
  category_key:
    title: 'Category Name'
    dir: '/category/path'
labels:
  label_key: 'Label title'
```

## Development

### Run DynamoDB Local
```
docker-compose -f docker/docker-compose.yml up
```

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/carraway. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Carraway project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/carraway/blob/master/CODE_OF_CONDUCT.md).
