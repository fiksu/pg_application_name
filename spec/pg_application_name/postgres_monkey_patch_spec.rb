require 'spec_helper'

module ActiveRecord::ConnectionAdapters
  describe PostgreSQLAdapter do

    describe "set_server_variable" do
      context "when call the method with safe params" do
        it "sets application name to the 'New name'" do
          ActiveRecord::Base.connection.set_server_variable(:application_name, "New name")
          ActiveRecord::Base.connection.execute("select application_name from pg_stat_activity;").
              values.flatten.select{|app_name| app_name == "New name"}.should have(1).item
        end
      end # when call the method with safe params

      context "when call the method without safe params" do
        it "injection did not work" do
          ActiveRecord::Base.connection.
              set_server_variable(:application_name, "New name'; select * from pg_stat_activity where application_name = 'New name").
              values.should be_blank
        end
      end # when call the method without safe params
    end # set_server_variable

    describe "get_user_variable" do
      context "when call the method with safe param" do
        it "returns user variable" do
          ActiveRecord::Base.connection.get_user_variable("application_name").
              should == "#{Rails.application.class.name}/#{Process.pid}"
        end
      end # when call the method with safe param

      context "when parameter has blank space" do
        it "returns nil" do
          ActiveRecord::Base.connection.get_user_variable("application name'").should be_nil
        end
      end # when parameter has blank space
    end # get_user_variable

    describe "set_server_application_name" do
      it "should receive set_server_variable method" do
        ActiveRecord::Base.connection.should_receive(:set_server_variable).with(:application_name, "new name")
        ActiveRecord::Base.connection.set_server_application_name("new name")
      end
    end # set_server_application_name

  end # PostgreSQLAdapter
end # ActiveRecord::ConnectionAdapters