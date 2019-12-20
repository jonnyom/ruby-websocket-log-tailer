# Log Tailer
This is a simple [Sinatra](http://sinatrarb.com/) app that emulates the Unix `tail -f` command.

It takes a given logfile and transmits the last ten lines of the file over a websocket connection
to any clients connected.

On any update to the logfile, all connected clients will see the updates in their session, without having to
reload the page.

If a new client connects after a change has been made, they will see the last ten lines _including_ any new changes
that have been made.

Uses a (relatively old, but stable) gem called Sinatra-Websocket, which gives websocket functionality out of the
box on top of Sinatra applications, making use of EventMachine.

### Application layout
The majority of the heavy lifting takes place in the `/io` directory. There are two classes that make up this module, and combined
they emulate the full `tail-f` command.

- TailF
    - This class reads the file and seeks the last 10 lines of the file.
    - It makes some decisions whether to use IO's native `seek` function or File's `readlines`
    method, depending on the size of the file.
- ChangesPoller
    - This class monitors the given file for any changes using a simple one second poller.
    - Every second, it reads the last modified time of the given file and compares it to the last one
    it's seen.
    - If there has been a change, calculate the difference in bytes and then read those into the
    websocket connection
    - To maintain the information about the file, a simple model, LogFileDetails has been implemented.
        - This class simply stores the data about the last read position of the file, and the last time
        it was modified.
        - It also has a method to abstract away the calculation of determining the last time the file was modified.

## Running the file
This is a Ruby application, to run it simply install the dependencies and execute the main file:
```shell script
~/D/p/log-tailer ❯❯❯ bundle install
~/D/p/log-tailer ❯❯❯ ruby app.rb
```     

You can access the client at http://localhost:4567/

I've included some sample log files that you can edit and play around with, if you do run this application.

## Running tests
Tests using RSpec
```shell script
~/D/p/log-tailer ❯❯❯ bundle exec rspec spec/
..........

Finished in 0.03997 seconds (files took 0.39372 seconds to load)
10 examples, 0 failures
```
