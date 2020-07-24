begin
  require 'bundler/inline'
rescue LoadError => e
  $stderr.puts 'Bundler version 1.10 or later is required. Please update your Bundler'
  raise e
end

gemfile(true) do
  source 'https://rubygems.org'

  gem 'chunky_png'
  gem 'escpos'
  gem 'escpos-image'
  gem 'action_cable_client'
  gem 'colorize'
end

def websocket_restart
  sleep 5
  exec 'ruby printer.rb'
  exit 0
end

def websocket_connection
  EventMachine.run do
    uri = "ws://localhost:3000/cable/?uid=navidad"
    client = ActionCableClient.new(uri, 'PrinterChannel')

    # called whenever a welcome message is received from the server
    client.connected { puts 'Successfully connected!'.green }

    # called whenever a disconnection occurs
    client.disconnected do 
      puts 'Disconnected, restarting...'.red
      websocket_restart
    end

    # called whenever a message is received from the server
    client.received do | message |
      ticket_text = message['message']
      puts ticket_text

      print(logo_escpos)
      print(ticket_text)
    end

    # Sends a message to the server, with the 'action', 'print'
    # client.perform('print', { message: 'hello from amc' })
  end
end

def logo_escpos
  printer = Escpos::Printer.new
  path = 'logo_bn.png'
  image = Escpos::Image.new( path, { processor: 'ChunkyPng' })
  printer.write(image.to_escpos)

  printer.to_escpos
end

def print(object)
  #puts "Printing #{object}"

  File.open('/dev/usb/lp0', 'w:ascii-8bit') { |f| f.write(object) }
end

websocket_connection
