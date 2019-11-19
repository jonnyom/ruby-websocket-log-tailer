require "spec_helper"

describe LogFileDetails do
  it "creates a new LogFileDetails class" do
    log_file_details = described_class.new(last_modified_time: 1234, last_read_position: 12345)
    expect(log_file_details.last_modified_time).to eq(1234)
    expect(log_file_details.last_read_position).to eq(12345)
  end

  it "returns a boolean if the file has been modified recently" do
    log_file_details = described_class.new(last_modified_time: 1234, last_read_position: 12345)
    expect(log_file_details.recently_updated?(new_modified_time: 123456)).to eq(true)
  end
end
