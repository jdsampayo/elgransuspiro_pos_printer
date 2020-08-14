# elgransuspiro_pos_printer
Printer client for Point Of Sale

- Install dependencies:

`sudo apt-get install build-essential libssl-dev ruby ruby-dev`

- Create a permanent cookie on the browser of the branch to listen those messages:

https://pos.elgransuspiro.com/sucursales?nombre=BRANCH_NAME

- Run client:

`ruby printer.rb`

![Ticket printed](https://elgransuspiro.com/pos_printer.png)

- Move service to

`/lib/systemd/system/pos_printer.service`

- Start/Check/Restart the service

`sudo systemctl start pos_printer`

Accept also: `status/restart/stop`

- Enable the service at boot

`sudo systemctl enable pos_printer`
