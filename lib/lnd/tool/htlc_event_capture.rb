module LND
  module Tool

    # Use SubscribeHtlcEvents to get HTLC events from LND and store them in the DB.
    class HTLCEventCapture

      attr_reader :client

      def initialize(config)
        @client = Lnrpc::Client.new({
                                      credentials_path: config['credentials_path'],
                                      macaroon_path: config['macaroon_path'],
                                      address: "#{config['host']}:#{config['port']}"
                                    })
      end

      # Start capture.
      def start
        store = Store::HTLCEvent.new
        client.router.subscribe_htlc_events.each do |htlc_event|
          puts htlc_event
          store.save(htlc_event)
        end
      end

    end
  end
end
