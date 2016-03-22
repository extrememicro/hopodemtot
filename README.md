![hopodemtot logo]
(https://raw.githubusercontent.com/extrememicro/hopodemtot/master/app/assets/images/hopodemtot-logo.png)

# Ho Podem Tot

Citizen Participation and Open Government Application

[![Circle CI](https://circleci.com/gh/extrememicro/hopodemtot/tree/master.svg?style=svg)](https://circleci.com/gh/extrememicro/hopodemtot/tree/master)
[![Coverage Status](https://coveralls.io/repos/github/extrememicro/hopodemtot/badge.svg?branch=master)](https://coveralls.io/github/extrememicro/hopodemtot?branch=master)
[![Code Climate](https://codeclimate.com/github/extrememicro/hopodemtot/badges/gpa.svg)](https://codeclimate.com/github/extrememicro/hopodemtot)
[![Dependency Status](https://gemnasium.com/extrememicro/hopodemtot.svg)](https://gemnasium.com/extrememicro/hopodemtot)
[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

This is the opensource code repository for "ara.hopodemtot.info", based on [Consul](https://github.com/consul/consul), developed by the Madrid City government and "decidim.barcelona" (Barcelona City Government).

## Tech stack

The application backend is written in the [Ruby language](https://www.ruby-lang.org/) using the [Ruby on Rails](http://rubyonrails.org/) framework.

Frontend tools used include [SCSS](http://sass-lang.com/) over [Foundation](http://foundation.zurb.com/) for the styles.

## Configuration for development environment using Docker

Docker is the recommended development environment as it guarantees library parity, as well as a predictable an easy to set up development environment.

```
docker-compose build
docker-compose run --rm app db:create           
docker-compose run --rm app db:setup SEED=true
docker-compose up
```


```
docker-compose build
docker-compose run app bash -c 'bundle install && rake db:setup'

if [[ -e ~/docker/image.tar ]]; then docker load -i ~/docker/image.tar; fi
sudo pip install --upgrade docker-compose==1.5.2
docker pull ultrayoshi/ruby-node-phantomjs:2.1.1
docker pull postgres
docker pull redis
docker-compose build
docker-compose run app bundle install
docker-compose run app npm install
docker-compose run app webpack 
docker-compose run app bundle exec rake db:setup SEED=TRUE
mkdir -p ~/docker; docker save ultrayoshi/ruby-node-phantomjs:2.1.1 postgres redis > ~/docker/image.tar
docker-compose run app rake db:setup
docker-compose run -e RAILS_ENV=test app bundle exec rake assets:precompile
```


## Configuration for development and test environments

Prerequisites: install git, ImageMagick, Ruby 2.2.3, bundler gem, redis, ghostscript and PostgreSQL (>=9.4).

```
git clone https://github.com/AjuntamentdeBarcelona/decidimbcn.git
cd decidimbcn
bundle install
cp config/database.yml.example config/database.yml
cp config/secrets.yml.example config/secrets.yml
rake db:create
bin/rake db:setup
bin/rake db:dev_seed
RAILS_ENV=test bin/rake db:setup
```

Run the app locally:
```
bin/rails s
```

Prerequisites for testing: install PhantomJS >= 2.0

Run the tests with:

```
bin/rspec
```

```
docker-compose run app bundle exec rspec
```

## Licence

Code published under AFFERO GPL v3 (see [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt))

## Contributions

See [CONTRIBUTING.md](CONTRIBUTING.md)

## Code of conduct

See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
