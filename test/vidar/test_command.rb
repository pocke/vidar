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

  def test_command_run_validate_non_interger_or_boolean
    klass = Class.new do
      def i; 0 end
      def t; true end
      def f; false end
      def n; nil end
      def s; 'meow' end
    end

    c = Vidar::Command.new(klass.new.method(:i))
    assert_equal 0, c.run([])
    c = Vidar::Command.new(klass.new.method(:t))
    assert_equal true, c.run([])
    c = Vidar::Command.new(klass.new.method(:f))
    assert_equal false, c.run([])
    c = Vidar::Command.new(klass.new.method(:n))
    err = assert_raises(Vidar::Errors::InvalidExitStatus) { c.run([]) }
    assert_equal 'n should return an Integer, true or false. But it returns nil', err.message
    c = Vidar::Command.new(klass.new.method(:s))
    err = assert_raises(Vidar::Errors::InvalidExitStatus) { c.run([]) }
    assert_equal 's should return an Integer, true or false. But it returns "meow"', err.message
  end
end
