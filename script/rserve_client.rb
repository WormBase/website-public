#!/usr/bin/ruby

require 'rubygems'
require 'rserve'

# Create a connection with the Rserve server, which listens
# on TCP port 6311 by default.
rserve = Rserve::Connection.new

# Read an R script from standard input, line-by-line:
STDIN.each { |line|
  begin
    # Feed the line to R and output the result.
    puts rserve.eval(line).to_ruby
  rescue => error
    # If there was an error (a.k.a. "exception"), then print this instead
    # and exit this script with an error code of 1.
    puts "#{error}"
    exit 1
  end
}

