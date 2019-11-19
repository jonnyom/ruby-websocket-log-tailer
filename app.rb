require "sinatra"
require "sinatra-websocket"
require "./models/log_file_details"
require "./io/tail_f"
require "./io/changes_poller"

set :server, "thin"
set :sockets, []

LOG_FILE = "./examples/example_logs.log"

get "/" do
  if !request.websocket?
    erb :index
  else
    request.websocket do |websocket|
      websocket.onopen do
        file = File.open(LOG_FILE)
        settings.sockets << websocket
        send_tailed_logs(websocket, file)
        poll_for_changes(websocket, file)
      rescue Errno::ENOENT, Errno::EINVAL
        websocket.send("Something went wrong reading #{LOG_FILE}")
      rescue EncodingError
        websocket.send("Error encoding logfile")
      end
      websocket.onclose do
        warn("websocket closed")
        settings.sockets.delete(websocket)
      end
    end
  end
end

private def send_tailed_logs(websocket, file)
  tailed_logs = Io::TailF.tail(file, 10)

  tailed_logs.each do |log|
    encoded_log = log.encode!(Encoding::UTF_8)
    websocket.send(encoded_log)
  end
end

private def poll_for_changes(websocket, file)
  log_file_details = LogFileDetails.new(
    last_modified_time: file.mtime.to_i,
    last_read_position: file.stat.size
  )

  Io::ChangesPoller.send_updates(
    websocket: websocket,
    log_file_details: log_file_details,
    log_file: LOG_FILE
  )
end
