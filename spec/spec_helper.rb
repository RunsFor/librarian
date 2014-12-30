require 'simplecov'
require 'vcr'
require 'webmock'
require 'pry'
require 'librarian'

SimpleCov.start do
  add_filter 'spec/'
  add_group 'Lib', 'lib/'
end


