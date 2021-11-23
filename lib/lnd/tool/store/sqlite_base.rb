require 'sqlite3'

module LND
  module Tool
    module Store
      # Abstract class for store.
      class SQLiteBase

        attr_reader :db

        def initialize(path)
          @db = SQLite3::Database.new(path)
          setup
        end

        def setup
          raise Error, 'Inherit and implement the setup method.'
        end
      end
    end
  end
end
