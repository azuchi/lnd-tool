# frozen_string_literal: true

RSpec.describe LND::Tool do
  it 'has a version number' do
    expect(LND::Tool::VERSION).not_to be nil
  end
end
