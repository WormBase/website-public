#!/usr/bin/ruby

require 'rubygems'
require 'rserve'

rserve = Rserve::Connection.new

STDIN.each { |line|
  begin
    puts rserve.eval(line).to_ruby
  rescue => error
    puts "#{error}"
    exit 1
  end
}

