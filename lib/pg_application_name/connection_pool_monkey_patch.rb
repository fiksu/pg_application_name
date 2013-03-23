require 'active_record'
require 'active_record/base'
require 'active_record/connection_adapters/abstract/connection_pool'

module ActiveRecord
  module ConnectionAdapters
    class ConnectionPool
      @connection_application_name = nil

      def self.connection_application_name=(value)
        return @connection_application_name = value
      end

      def self.connection_application_name
        if @connection_application_name.blank?
          @connection_application_name = "#{Rails.application.class.name}/#{Process.pid}"
        end
        return @connection_application_name
      end

      def self.initialize_connection_application_name(application_name)
        self.connection_application_name = application_name
        if ActiveRecord::Base.connection.respond_to? :set_server_application_name
          ActiveRecord::Base.connection.set_server_application_name(self.connection_application_name)
        end
      end

      private
      def new_connection_with_set_application_name
        c = new_connection_without_set_application_name
        if c.respond_to? :set_server_application_name
          c.set_server_application_name(self.class.connection_application_name)
        end
        c
      end
      alias_method_chain :new_connection, :set_application_name
    end
  end
end
