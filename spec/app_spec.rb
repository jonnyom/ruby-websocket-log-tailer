require "spec_helper"

describe "App" do
  it "responds successfully" do
    get "/"
    expect(last_response).to be_ok
  end

  context "With a websocket present" do
    let(:websocket_double) { double("Websocket") }

    before do
      expect_any_instance_of(SinatraWebsocket::Ext::Sinatra::Request).to receive(:websocket?).and_return(true)
      expect_any_instance_of(SinatraWebsocket::Ext::Sinatra::Request).to receive(:websocket).and_yield(websocket_double)
      allow(websocket_double).to receive(:onclose)
    end

    it "opens the connection and sends exactly 10 log lines" do
      expect(websocket_double).to receive(:send).exactly(10).times
      expect(websocket_double).to receive(:onopen) do |&block|
        block.call
      end
      get "/"
    end
  end
end
