# Log
#$stdout.reopen('daemon.log', 'a')
#$stdout.sync = true

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

def websocket_connection
  EventMachine.run do
    uri = 'wss://pos.elgransuspiro.com/cable/?uid=branch_name'
    tls = {cert_chain_file: 'fullchain.pem', private_key_file: 'privkey.pem'}
    client = ActionCableClient.new(uri, 'PrinterChannel', true, nil, tls)

    # called whenever a welcome message is received from the server
    client.connected { puts 'Successfully connected!'.green }

    # called whenever a disconnection occurs
    client.disconnected do 
      puts 'Disconnected'.red
    end

    # called whenever a message is received from the server
    client.received do | message |
      ticket_text = message['message']
      puts ticket_text

      print(logo_escpos)
      print(ticket_text)
    end

    # Sends a message to the server, with the 'action', 'print'
    # client.perform('print', { message: 'hello from printer' })
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
  File.open('/dev/usb/lp0', 'w:ascii-8bit') { |f| f.write(object) }
end

websocket_connection
