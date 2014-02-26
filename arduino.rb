require 'serialport'
require 'json'
require 'firebase'
require 'dotenv'
require 'logging'

logger = Logging.logger['example_logger']
logger.add_appenders(
  Logging.appenders.stdout,
  Logging.appenders.file('example.log')
)

Dotenv.load

firebase = Firebase.new(ENV['FIREBASE_URL'], ENV['SECRET_TOKEN'])

port_str = ENV['USB_SERIAL']
baud_rate = 9600
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE
logger.info "Using port: " + ENV['USB_SERIAL']
sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)

while true do
  while (i = sp.gets.chomp) do
    begin
      parsed = JSON.parse(i).merge(time: Time.now)
      logger.info "Received #{parsed} from Arduino"
      response = firebase.push(:temperature, parsed)
      logger.info "Firebase response: #{response.code}"
    rescue JSON::ParserError => e
      logger.error e
    end
  end
end

sp.close
