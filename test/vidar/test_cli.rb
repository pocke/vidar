require 'test_helper'
require 'stringio'

class TestVidarCLI < Minitest::Test
  def exit_with(status, &block)
    block.call
  rescue SystemExit => ex
    assert_equal status, ex.status
  else
    refuse
  end

  def stdout_with(expect, &block)
    stdout = $stdout
    $stdout = StringIO.new
    block.call
  ensure
    assert_equal expect, $stdout.string
    $stdout = stdout
  end

  def test_run_subcommand
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

  def test_run_main_command
    cli = Vidar::CLI.new
    cli.mount(Class.new do
      def main(name)
        puts "hello, #{name}"
        0
      end
    end, :main)

    exit_with(0) {
      stdout_with("hello, pocke\n") { cli.run!(%w[pocke]) }
    }
  end
end
