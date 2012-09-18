require 'active_record'
require 'active_record/base'
require 'active_record/connection_adapters/abstract_adapter'

module ActiveRecord::ConnectionAdapters
  class PostgreSQLAdapter < AbstractAdapter
    def set_server_variable(var, value)
      if var[0...63].to_s.split(' ').size == 1
        value = value[0...63].to_s.gsub(/'/, "''")
        execute("set #{var} = '#{value}'")
      end
    end

    def get_user_variable(var)
      if var[0...63].split(' ').size == 1
        return execute("show #{var}").values[0][0]
      end
    end

    def set_server_application_name(value)
      set_server_variable(:application_name, value)
    end
  end
end
