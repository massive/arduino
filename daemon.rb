require 'rubygems'
require 'daemons'
require 'dotenv'
Dotenv.load

Daemons.run('arduino.rb')
