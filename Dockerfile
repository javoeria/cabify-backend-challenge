FROM ruby:3.3.3-alpine

# Install dependencies
RUN apk update && apk add --no-cache build-base sqlite-dev

# Set up the working directory
WORKDIR /app
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Add the application code
COPY . .

# Expose port 9091
EXPOSE 9091

# Command to run the rails server
CMD [ "bin/rails", "server", "-b", "0.0.0.0", "-p", "9091" ]
