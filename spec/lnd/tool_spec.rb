# frozen_string_literal: true

RSpec.describe Lnd::Tool do
  it "has a version number" do
    expect(Lnd::Tool::VERSION).not_to be nil
  end
end
