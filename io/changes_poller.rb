module Io
  class ChangesPoller
    class << self
      def send_updates(websocket:, log_file_details:, log_file:)
        poll_each_second do
          last_read_position = log_file_details.last_read_position

          if log_file_details.recently_updated?(new_modified_time: File.mtime(log_file).to_i)
            file = File.open(log_file)
            new_file_size = file.stat.size
            send_new_messages(websocket, last_read_position, file, new_file_size)
            log_file_details = LogFileDetails.new(last_modified_time: file.mtime.to_i, last_read_position: new_file_size)
          end
        end
      end

      # Using the last read position of the file (the old EOF)
      # calculate the length of the changed bytes and read that from the file
      # Send that down the websocket connection, splitting on \n to the end user
      private def send_new_messages(websocket, last_read_position, file, file_size)
        return websocket.send("File not found") if file.nil?
        return websocket.send("Last read position not found") if last_read_position.nil?
        return websocket.send("New file size not found") if file_size.nil?

        file.seek(last_read_position + 1)
        block_length = file_size - last_read_position
        return websocket.send("Empty log") if block_length.negative?

        last_read = file.read(block_length)
        last_read.split("\n").each do |line|
          encoded_line = line.encode!(Encoding::UTF_8)
          websocket.send(encoded_line)
        end
      rescue Errno::EINVAL
        websocket.send("Invalid last read position")
      end

      private def poll_each_second
        return yield if ENV["RACK_ENV"] == "test"

        last = Time.now
        while true
          yield
          now = Time.now
          _next = [last + 1, now].max
          sleep(_next - now)
          last = _next
        end
      end
    end
  end
end
