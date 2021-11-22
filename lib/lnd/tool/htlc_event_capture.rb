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
        client.router.subscribe_htlc_events.each do |response|
          puts response
        end
      end

    end
  end
end
