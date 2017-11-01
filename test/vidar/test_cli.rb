require 'test_helper'

class TestVidarCLI < Minitest::Test
  def exit_with(status, &block)
    block.call
  rescue SystemExit => ex
    assert_equal status, ex.status
  else
    refuse
  end

  def test_run
    cli = Vidar::CLI.new
    cli.mount_subcommand(Class.new do
      def foo
        return 0
      end

      def bar
        return 1
      end
    end)

    exit_with(0) { cli.run!(%w[foo]) }
    exit_with(1) { cli.run!(%w[bar]) }
  end
end
