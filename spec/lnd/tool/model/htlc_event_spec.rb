# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LND::Tool::Store::HTLCEvent do

  let(:insufficient_error) do
    info = Routerrpc::HtlcInfo.new(incoming_timelock: 710_964, outgoing_timelock: 710_924,
                                   incoming_amt_msat: 300_005_300, outgoing_amt_msat: 300_001_300)
    fail_event = Routerrpc::LinkFailEvent.new(info: info, wire_failure: :TEMPORARY_CHANNEL_FAILURE,
                                              failure_detail: :INSUFFICIENT_BALANCE,
                                              failure_string: 'insufficient bandwidth to route htlc')
    Routerrpc::HtlcEvent.new(incoming_channel_id: 759_077_539_161_571_329, outgoing_channel_id: 781_080_965_883_559_937,
                             incoming_htlc_id: 181, outgoing_htlc_id: 0, timestamp_ns: 1_637_590_236_680_277_182,
                             event_type: :FORWARD, link_fail_event: fail_event)
  end
  let(:unknown_next_peer_error) do
    info = Routerrpc::HtlcInfo.new(incoming_timelock: 711_185, outgoing_timelock: 711_145,
                                   incoming_amt_msat: 210_395_813, outgoing_amt_msat: 210_289_879)
    fail_event = Routerrpc::LinkFailEvent.new(info: info, wire_failure: :UNKNOWN_NEXT_PEER,
                                              failure_detail: :NO_DETAIL,
                                              failure_string: 'UnknownNextPeer')
    Routerrpc::HtlcEvent.new(incoming_channel_id: 781_080_965_883_559_937, outgoing_channel_id: 759_526_139_822_866_433,
                             incoming_htlc_id: 1, outgoing_htlc_id: 0, timestamp_ns: 1_637_607_169_647_344_635,
                             event_type: :FORWARD, link_fail_event: fail_event)
  end
  let(:send_data) do
    Routerrpc::HtlcEvent.new(incoming_channel_id: 781_080_965_883_559_937, outgoing_channel_id: 759_526_139_822_866_433,
                             incoming_htlc_id: 1, outgoing_htlc_id: 0, timestamp_ns: 1_637_607_169_647_344_635,
                             event_type: :SEND, settle_event: Routerrpc::SettleEvent.new)
  end

  describe 'save and all' do
    it 'should be stored.' do
      store = LND::Tool::Store::HTLCEvent.new(random_db_path)
      store.save(insufficient_error)
      sleep 1
      store.save(unknown_next_peer_error)
      results = store.all.to_a
      expect(results.size).to eq(2)
      expect(results[0].event_type).to eq(:FORWARD)
      expect(results[0].link_fail_event.wire_failure).to eq(:UNKNOWN_NEXT_PEER)
      expect(results[1].link_fail_event.wire_failure).to eq(:TEMPORARY_CHANNEL_FAILURE)
    end
  end

  describe '#query' do
    it 'should be applied condition' do
      store = LND::Tool::Store::HTLCEvent.new(random_db_path)
      store.save(insufficient_error)
      store.save(unknown_next_peer_error)
      store.save(send_data)
      expect(store.query.to_a.size).to eq(3)
      send = store.query(event_type: 'SEND').to_a
      expect(send.size).to eq(1)
      expect(send.first.event_type).to eq(:SEND)
      expect(store.query(limit: 1).to_a.size).to eq(1)
    end
  end

end
