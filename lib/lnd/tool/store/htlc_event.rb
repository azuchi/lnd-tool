module LND
  module Tool
    module Store
      # HTLC event store
      class HTLCEvent < SQLiteBase

        # Setup table.
        def setup
          query = <<~SQL
            CREATE TABLE IF NOT EXISTS HtlcEvent(
            id INTEGER PRIMARY KEY,
            incoming_channel_id INTEGER,
            outgoing_channel_id INTEGER,
            incoming_htlc_id INTEGER,
            outgoing_htlc_id INTEGER,
            timestamp_ns INTEGER,
            event_type TEXT,
            forward_event TEXT,
            forward_fail_event TEXT,
            settle_event TEXT,
            link_fail_event TEXT,
            created_datetime TIMESTAMP DEFAULT (datetime(CURRENT_TIMESTAMP,'localtime')))
          SQL
          db.execute(query)
        end

        # Save htlc event.
        # @param [Routerrpc::HtlcEvent] event HTLC event
        def save(event)
          query = <<~SQL
            INSERT INTO HtlcEvent (incoming_channel_id, outgoing_channel_id,
            incoming_htlc_id, outgoing_htlc_id, timestamp_ns, event_type, forward_event, forward_fail_event,
            settle_event, link_fail_event) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          SQL
          values = [
            event.incoming_channel_id,
            event.outgoing_channel_id,
            event.incoming_htlc_id,
            event.outgoing_htlc_id,
            event.timestamp_ns,
            event.event_type.to_s,
            event.forward_event ? Routerrpc::ForwardEvent.encode_json(event.forward_event) : nil,
            event.forward_fail_event ? Routerrpc::ForwardFailEvent.encode_json(event.forward_fail_event) : nil,
            event.settle_event ? Routerrpc::SettleEvent.encode_json(event.settle_event) : nil,
            event.link_fail_event ? Routerrpc::LinkFailEvent.encode_json(event.link_fail_event) : nil
          ]
          db.execute(query, values)
        end

        # Query all data.
        # @return [Enumerator::Lazy]
        def all
          query = <<~SQL
            SELECT incoming_channel_id, outgoing_channel_id,
            incoming_htlc_id, outgoing_htlc_id, timestamp_ns, event_type, forward_event, forward_fail_event,
            settle_event, link_fail_event FROM HtlcEvent ORDER BY created_datetime DESC
          SQL
          db.query(query).lazy.map do |result|
            forward_event = result[6] ? Routerrpc::ForwardEvent.decode_json(result[6]) : nil
            forward_fail_event = result[7] ? Routerrpc::ForwardFailEvent.decode_json(result[7]) : nil
            settle_event = result[8] ? Routerrpc::SettleEvent.decode_json(result[8]) : nil
            link_fail_event = result[9] ? Routerrpc::LinkFailEvent.decode_json(result[9]) : nil
            Routerrpc::HtlcEvent.new(incoming_channel_id: result[0],
                                     outgoing_channel_id: result[1],
                                     incoming_htlc_id: result[2],
                                     outgoing_htlc_id: result[3],
                                     timestamp_ns: result[4],
                                     event_type: result[5].to_sym,
                                     forward_event: forward_event,
                                     forward_fail_event: forward_fail_event,
                                     settle_event: settle_event,
                                     link_fail_event: link_fail_event)
          end
        end
      end
    end
  end
end
