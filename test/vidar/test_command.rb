require 'test_helper'

class TestVidarCommand < Minitest::Test
  def klass
    @klass ||= Class.new do
      def foo
        return 0
      end

      def bar
        return 1
      end

      def i; 0 end
      def t; true end
      def f; false end
      def n; nil end
      def s; 'meow' end

      def req(a) true end
      def req_req_req(a, b, c) true end
      def req_opt_req(a, b = 1, c) true end
      def req_opt_opt(a, b = 1, c = 1) true end
      def req_opt_rest(a, b = 1, *c) true end
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

  def test_command_validate_too_few_arguments
    too_few_arg = proc do |&block|
      ex = assert_raises(Vidar::Errors::CLIArgumentError, &block)
      assert_equal 'Too few arguments', ex.message
    end

    c = Vidar::Command.new(klass.new.method(:req))
    too_few_arg.(&-> () { c.run([]) })
    assert_equal true, c.run([1])

    c = Vidar::Command.new(klass.new.method(:req_req_req))
    too_few_arg.(&-> () { c.run([]) })
    too_few_arg.(&-> () { c.run([1]) })
    too_few_arg.(&-> () { c.run([1, 2]) })
    assert_equal true, c.run([1, 2, 3])

    c = Vidar::Command.new(klass.new.method(:req_opt_req))
    too_few_arg.(&-> () { c.run([]) })
    too_few_arg.(&-> () { c.run([1]) })
    assert_equal true, c.run([1, 2])

    c = Vidar::Command.new(klass.new.method(:req_opt_opt))
    too_few_arg.(&-> () { c.run([]) })
    assert_equal true, c.run([1])
  end

  def test_command_validate_too_many_arguments
    too_many_arg = proc do |&block|
      ex = assert_raises(Vidar::Errors::CLIArgumentError, &block)
      assert_equal 'Too many arguments', ex.message
    end

    c = Vidar::Command.new(klass.new.method(:req))
    assert_equal true, c.run([1])
    too_many_arg.(&-> () { c.run([1, 2]) })

    c = Vidar::Command.new(klass.new.method(:req_req_req))
    assert_equal true, c.run([1, 2, 3])
    too_many_arg.(&-> () { c.run([1, 2, 3, 4]) })

    c = Vidar::Command.new(klass.new.method(:req_opt_req))
    assert_equal true, c.run([1, 2])
    assert_equal true, c.run([1, 2, 3])
    too_many_arg.(&-> () { c.run([1, 2, 3, 4]) })

    c = Vidar::Command.new(klass.new.method(:req_opt_opt))
    assert_equal true, c.run([1])
    assert_equal true, c.run([1, 2])
    assert_equal true, c.run([1, 2, 3])
    too_many_arg.(&-> () { c.run([1, 2, 3, 4]) })
  end
end
