require "serialport"
require 'json'
require 'firebase'

firebase = Firebase.new(ENV['FIREBASE_URL'], ENV['SECRET_TOKEN'])

port_str = ENV['USB_SERIAL']
baud_rate = 9600
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE

sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)

while true do
  while (i = sp.gets.chomp) do
    begin
      parsed = JSON.parse(i).merge(time: Time.now)
      puts "Received #{parsed} from Arduino"
      response = firebase.push(:temperature, parsed)
      puts "Firebase response: #{response.code}"
    rescue JSON::ParserError => e
      puts e
    end
  end
end

sp.close
