require "spec_helper"

describe Io::TailF do
  let(:long_test_file_name) { "#{RSPEC_ROOT}/examples/longer_test_logs.log" }
  let(:small_test_file_name) { "#{RSPEC_ROOT}/examples/test_logs.log" }
  let(:long_test_file) { File.open(long_test_file_name) }
  let(:small_test_file) { File.open(small_test_file_name) }
  let(:empty_file) { File.open("tmp.txt", "w") }

  context "for small files" do
    before { allow(small_test_file).to receive(:readlines) { ["Testing testing", "Another test"] } }

    it "simply reverses the files readlines" do
      result = described_class.tail(small_test_file, 10)
      expect(result).to eq(["Another test", "Testing testing"])
    end
  end

  context "For longer files" do
    let(:expected_result) do
      [
        "Testing testing1",
        "Testing testing2",
        "Testing testing3",
        "Testing testing4",
        "Testing testing5",
        "Testing testing6",
        "Testing testing7",
        "Testing testing8",
        "Testing testing9",
        "Testing testing10"
      ].reverse
    end

    it "doesn't use readlines and tails from the end of the file" do
      expect(long_test_file).to_not receive(:readlines)
      result = described_class.tail(long_test_file, 10)
      expect(result).to eq(expected_result)
    end
  end

  context "with invalid output_length argument" do
    it "returns an empty array" do
      expect(described_class.tail(long_test_file, 0)).to eq([])
    end
  end

  it "returns an empty array when the tail_buffer_length is invalid" do
    expect(described_class.tail(empty_file, 10)).to eq([])
  end

  after do
    long_test_file.close
    small_test_file.close
    empty_file.close
    File.delete(empty_file)
  end
end
