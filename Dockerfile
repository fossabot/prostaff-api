# Use Ruby 3.2 Alpine image for smaller size
FROM ruby:3.2-alpine

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    git \
    tzdata \
    nodejs \
    yarn

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install Ruby dependencies
RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3

# Copy application code
COPY . .

# Create user to run the application
RUN addgroup -g 1000 -S app && \
    adduser -u 1000 -S app -G app

# Change ownership of the app directory
RUN chown -R app:app /app

# Switch to the app user
USER app

# Expose port 3333
EXPOSE 3333

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3333/up || exit 1

# Start the Rails server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]