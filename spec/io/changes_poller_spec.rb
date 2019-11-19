require "spec_helper"

describe Io::ChangesPoller do
  let(:test_file_name) { "#{RSPEC_ROOT}/examples/test_logs.log" }
  let(:websocket_double) { double("websocket") }
  let(:log_file_details) { LogFileDetails.new(last_read_position: last_read_position, last_modified_time: 12345) }

  context "with an invalid last read position" do
    let(:last_read_position) { -1000 }

    it "Reports the error gracefully" do
      expect(websocket_double).to receive_message_chain(:send).with("Invalid last read position")
      described_class.send_updates(log_file_details: log_file_details, websocket: websocket_double, log_file: test_file_name)
    end
  end

  context "with an updated file" do
    let(:last_read_position) { -1 }
    before { allow(log_file_details).to receive(:recently_updated?).and_return(true) }

    it "Doesn't fail and reports an empty logfile" do
      expect(websocket_double).to receive_message_chain(:send).with("Testing testing")
      described_class.send_updates(log_file_details: log_file_details, websocket: websocket_double, log_file: test_file_name)
    end
  end
end
