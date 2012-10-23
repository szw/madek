require 'rubygems'
require 'spork'
require 'pry'

require 'simplecov'
SimpleCov.start 'rails' do
  merge_timeout 3600
end

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
end

Spork.each_run do
  # This code will be run each time you run your specs.
end

# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a 
# newer version of cucumber-rails. Consider adding your own code to a new file 
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

require 'cucumber/rails'

# Capybara defaults to XPath selectors rather than Webrat's default of CSS3. In
# order to ease the transition to Capybara we set the default here. If you'd
# prefer to use XPath just remove this line and adjust any selectors in your
# steps to use the XPath syntax.
Capybara.default_selector = :css

# By default, any exception happening in your Rails application will bubble up
# to Cucumber so that your scenario will fail. This is a different from how 
# your application behaves in the production environment, where an error page will 
# be rendered instead.
#
# Sometimes we want to override this default behaviour and allow Rails to rescue
# exceptions and display an error page (just like when the app is running in production).
# Typical scenarios where you want to do this is when you test your error pages.
# There are two ways to allow Rails to rescue exceptions:
#
# 1) Tag your scenario (or feature) with @allow-rescue
#
# 2) Set the value below to true. Beware that doing this globally is not
# recommended as it will mask a lot of errors for you!
#
ActionController::Base.allow_rescue = false

# Remove/comment out the lines below if your app doesn't have a database.
# For some databases (like MongoDB and CouchDB) you may need to use :truncation instead.

our_default_strategy = :transaction

begin
  DatabaseCleaner.strategy = our_default_strategy
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end


FileUtils.rm_rf("#{Rails.root}/tmp/dropbox")
FileUtils.mkdir("#{Rails.root}/tmp/dropbox")
at_exit do
  # remove dropbox 
  FileUtils.rm_rf("#{Rails.root}/tmp/dropbox")
end


# Override some JavaScript behavior to help against these problems:
# https://github.com/cucumber/cucumber-rails/blob/master/features/choose_javascript_database_strategy.feature
# https://github.com/cucumber/cucumber-rails/issues/180
# There's a summary of the fuckedupness here: https://github.com/cucumber/cucumber-rails/issues/166
Before('@javascript, ~@transactional') do
  DatabaseCleaner.strategy = :truncation
  PersonasDBHelper.clone_persona_to_test_db

end

After('@javascript, ~@transactional') do
  DatabaseCleaner.strategy = our_default_strategy
  # close any alert message to not disturb following tests
  begin
    page.driver.browser.switch_to.alert.accept
  rescue #silently
  end
end

Before do
  # The path would be wrong, it might point, it might point to some developer's homedir or the
  # persona server's home dir etc.
  AppSettings.dropbox_root_dir = (Rails.root + "tmp/dropbox").to_s

  DatabaseCleaner.start
end

After do |scenario|
  DatabaseCleaner.clean
end
