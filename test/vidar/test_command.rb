require 'test_helper'

class TestVidarCommand < Minitest::Test
  def klass
    Class.new do
      def foo
        return 0
      end

      def bar
        return 1
      end
    end
  end

  def test_command_new
    Vidar::Command.new(klass.new.method(:foo))
    Vidar::Command.new(klass.new.method(:bar))
  end

  def test_command_run
    c = Vidar::Command.new(klass.new.method(:foo))
    assert_equal 0, c.run([])
    c = Vidar::Command.new(klass.new.method(:bar))
    assert_equal 1, c.run([])
  end
end
