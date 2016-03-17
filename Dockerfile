FROM ultrayoshi/ruby-node-phantomjs:2.1.1
MAINTAINER david.morcillo@codegram.com

# Create working directory
ENV APP_HOME /hopodemtot
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Add source code
ADD . $APP_HOME

# Install webpack
RUN npm install -g webpack

# Run rails server by default
CMD ["bundle" "exec" "puma", "-C config/puma.rb"]
