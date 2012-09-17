require 'spec_helper'

module ActiveRecord::ConnectionAdapters
  describe ConnectionPool do

    describe "#connection_application_name=" do
      it "sets @connection_application_name" do
        ActiveRecord::ConnectionAdapters::ConnectionPool.connection_application_name = "New name"
        ActiveRecord::ConnectionAdapters::ConnectionPool.
            instance_variable_get(:@connection_application_name).should == "New name"
      end
    end # #connection_application_name=

    describe "#connection_application_name" do
      context "when @connection_application_name is set" do
        it "returns @connection_application_name value" do
          ActiveRecord::ConnectionAdapters::ConnectionPool.connection_application_name.should == "New name"
        end
      end

      context "when @connection_application_name isn't set" do
        it "sets and returns @connection_application_name" do
          ActiveRecord::ConnectionAdapters::ConnectionPool.connection_application_name = nil
          ActiveRecord::ConnectionAdapters::ConnectionPool.connection_application_name.
              should == "#{Rails.application.class.name}/#{Process.pid}"
        end
      end
    end # #connection_application_name

    describe "#initialize_connection_application_name" do
      it "sets @connection_application_name and sets server_application_name" do
        ActiveRecord::ConnectionAdapters::ConnectionPool.initialize_connection_application_name("New application name")
        ActiveRecord::ConnectionAdapters::ConnectionPool.
            instance_variable_get(:@connection_application_name).should == "New application name"
        ActiveRecord::Base.connection.get_user_variable("application_name").should == "New application name"
      end
    end

    describe "alias_method_chain :new_connection, :set_application_name" do
      context "new_connection_without_set_application_name" do
        it "calls new_connection method" do
          ActiveRecord::Base.connection.set_server_variable(:application_name, "foo")
          ActiveRecord::Base.connection_pool.send(:new_connection_without_set_application_name)
          ActiveRecord::Base.connection.execute("select application_name from pg_stat_activity;").
              values.flatten.select{|app_name| app_name == "foo"}.should have(1).item
        end
      end # new_connection_without_set_application_name

      context "new_connection" do
        it "calls new_connection_with_set_application_name method" do
          ActiveRecord::Base.connection.set_server_variable(:application_name, "foo")
          ActiveRecord::ConnectionAdapters::ConnectionPool.connection_application_name = "bar"
          ActiveRecord::Base.connection_pool.send(:new_connection)
          ActiveRecord::Base.connection.execute("select application_name from pg_stat_activity;").
              values.flatten.select{|app_name| app_name == "bar"}.should have(1).item
        end
      end # new_connection
    end # new_connection_without_set_application_name

  end # ConnectionPool
end # ActiveRecord::ConnectionAdapters