require File.join(File.dirname(__FILE__), '..', 'test_helper')

class SshTest < Test::Unit::TestCase
  setup do
    @session = mock("session")

    @klass = Vagrant::SSH::Session
    @instance = @klass.new(@session)
  end

  context "exec!" do
    should "retry 5 times" do
      @session.expects(:open_channel).times(5).raises(IOError)
      assert_raises(IOError) {
        @instance.exec!("foo")
      }
    end
  end

  context "checking exit status" do
    should "raise an ActionException if its non-zero" do
      assert_raises(Vagrant::Actions::ActionException) {
        @instance.check_exit_status(1, "foo")
      }
    end

    should "raise the given exception if specified" do
      options = {
        :error_key => :foo,
        :error_data => {}
      }
      result = Exception.new
      Vagrant::Actions::ActionException.expects(:new).with(options[:error_key], options[:error_data]).once.returns(result)

      assert_raises(Exception) {
        @instance.check_exit_status(1, "foo", options)
      }
    end

    should "raise nothing if its zero" do
      assert_nothing_raised {
        @instance.check_exit_status(0, "foo")
      }
    end
  end
end
