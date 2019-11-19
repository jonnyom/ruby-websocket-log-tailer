module Io
  class TailF
    class << self
      def tail(file, output_length)
        return [] if output_length < 1

        tail_buffer_length = tail_buffer_length(file)
        return [] if tail_buffer_length <= 0

        # If the tail buffer is less than 100 bytes then we get very little advantage from seeking
        # Just reversing the files lines and reading to the output length should be fast enough
        return read_file_with_readlines(file, output_length) if tail_buffer_length < 100

        read_from_buffer(file, tail_buffer_length, output_length)
      end

      private def read_from_buffer(file, tail_buffer_length, output_length)
        return [] if file.nil?
        return [] if tail_buffer_length.nil? || tail_buffer_length.negative?

        file.seek(-tail_buffer_length, IO::SEEK_END)
        tailed_logs = ""
        newline_count = 0

        while newline_count <= output_length
          buffer = file.read(tail_buffer_length)
          newline_count += buffer.count("\n")
          tailed_logs << buffer
          file.seek(2 * -tail_buffer_length, IO::SEEK_CUR)
        end
        tailed_logs.split("\n")[-output_length..-1]
      end

      private def read_file_with_readlines(file, output_length)
        return [] if file.nil?
        return [] if output_length.nil? || output_length.negative?

        lines = file.readlines
        return lines.reverse if lines.length < output_length

        lines.reverse[-output_length..-1]
      end

      private def tail_buffer_length(file)
        return -1 if file.nil?
        # If the file is very small return a smaller seek offset to start searching from
        # If we need to jump further back in the file the main tail function will handle that.
        return file.size / 4 if file.size < (1 << 16)

        # A standard seek offset to search by
        1 << 16
      end
    end
  end

end
