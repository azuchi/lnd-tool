# frozen_string_literal: true

require_relative 'tool/version'
require 'lnrpc'

module LND
  module Tool
    class Error < StandardError; end
    # Your code goes here...

    autoload :Daemon, 'lnd/tool/daemon'
    autoload :Store, 'lnd/tool/store'
    autoload :HTLCEventCapture, 'lnd/tool/htlc_event_capture'

  end
end
