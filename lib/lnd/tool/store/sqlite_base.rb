require 'sqlite3'

module LND
  module Tool
    module Store
      # Abstract class for store.
      class SQLiteBase

        attr_reader :db

        # Initialize data store.
        # @param [Pathname] path data base path.
        def initialize(path = Daemon.db_path)
          @db = SQLite3::Database.new(path.to_s)
          setup
        end

        def setup
          raise Error, 'Inherit and implement the setup method.'
        end
      end
    end
  end
end
