#!/usr/bin/ruby

require 'rubygems'
require 'rserve'

# Create a connection with the Rserve server, which listens
# on TCP port 6311 by default.
rserve = Rserve::Connection.new

# R has a limit regarding line length, which is rediculously low (about 4k characters).
# This buffer accumulates lines for later execution using `eval`.
buffer = ''

# Read an R script from standard input, line-by-line:
STDIN.each { |line|
  begin
    next if line.start_with?('#') # Skip comments.

    # If the line does not end in a semi-colon, keep it in the buffer and read more lines.
    buffer << line
    next unless line.chomp.end_with?(';')

    # Feed the line to R and output the result.
    # puts buffer   # uncomment when debugging
    rserve.eval(buffer)
    buffer = ''
  rescue => error
    # If there was an error (a.k.a. "exception"), then print this instead
    # and exit this script with an error code of 1.
    puts "OOPS! an error occurred at: #{buffer}"
    puts "#{error}"
    exit 1
  end
}
