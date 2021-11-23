module LND
  module Tool
    module Store
      autoload :SQLiteBase, 'lnd/tool/store/sqlite_base'
      autoload :HTLCEvent, 'lnd/tool/store/htlc_event'
    end
  end
end
