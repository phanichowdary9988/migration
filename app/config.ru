require 'rack'
require_relative 'lib/bk/compat'
require_relative 'lib/bk/compat/server'

run BK::Compat::Server.new
