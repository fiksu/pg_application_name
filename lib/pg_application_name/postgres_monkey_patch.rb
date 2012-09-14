require 'active_record'
require 'active_record/base'
require 'active_record/connection_adapters/abstract_adapter'

module ActiveRecord::ConnectionAdapters
  class PostgreSQLAdapter < AbstractAdapter
    def set_server_variable(var, value)
      var = var.to_s.gsub(/'/, "''")
      value = value.to_s.gsub(/'/, "''")
      execute("set #{var} = '#{value}'")
    end

    def get_user_variable(var)
      var = var.gsub(/'/, "''")
      return execute("show #{var}").values[0][0]
    end

    def set_server_application_name(value)
      set_server_variable(:application_name, value)
    end
  end
end
