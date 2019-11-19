class LogFileDetails
  attr_accessor :last_modified_time, :last_read_position
  def initialize(last_modified_time:, last_read_position: nil)
    @last_modified_time = last_modified_time
    @last_read_position = last_read_position
  end

  def recently_updated?(new_modified_time:)
    last_modified_time < new_modified_time
  end
end
