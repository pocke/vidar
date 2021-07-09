require 'optparse'

require "vidar/version"

module Vidar
  module Errors
    class InvalidExitStatus < StandardError; end
    class CLIArgumentError < StandardError; end
  end

  class Command
    def initialize(method)
      @method = method
      @kwargs = {}

      mount
    end

    def run(argv)
      args = @option_parser.parse(argv)
      validate!(args, @kwargs)

      # https://bugs.ruby-lang.org/issues/11860
      if @kwargs.empty?
        @method.call(*args)
      else
        @method.call(*args, **@kwargs)
      end.tap do |exitstatus|
        case exitstatus
        when Integer, TrueClass, FalseClass
        else
          raise Errors::InvalidExitStatus, "#{@method.name} should return an Integer, true or false. But it returns #{exitstatus.inspect}"
        end
      end
    end

    private

    def mount
      @option_parser = OptionParser.new
      @parameters = @method.parameters

      @parameters.each do |type, name|
        case type
        when :req, :opt, :rest
          # TODO
          next
        when :keyreq, :key
          optname = name.size == 1 ? "-#{name}" : "--#{name.to_s.gsub('_', '-')}"
          optname << " VALUE"
          @option_parser.on(optname) {|value| @kwargs[name] = value}
        when :keyrest, :block
          raise "#{type} is not supported type!"
        else
          raise "#{type} is unknwon parameter type!"
        end
      end
    end

    def validate!(args, kwargs)
      req_count = @parameters.count {|t, _| t == :req}
      opt_count = @parameters.count {|t, _| t == :opt}
      rest_count = @parameters.count {|t, _| t == :rest}
      if req_count > args.size
        raise Errors::CLIArgumentError, 'Too few arguments'
      end
      if rest_count == 0 && (req_count + opt_count) < args.size
        raise Errors::CLIArgumentError, 'Too many arguments'
      end
    end
  end

  class CLI
    def initialize
      @subcommands = {}
      @main_command = nil
    end

    def mount(klass, method_name)
      instance = klass.new
      @main_command = Command.new(instance.method(method_name))
    end

    def mount_subcommand(klass)
      instance = klass.new
      instance.public_methods(false).each do |method_name|
        @subcommands[method_name] = Command.new(instance.method(method_name))
      end
    end

    def run!(argv)
      if @main_command
        @main_command.run(argv)
      else
        @subcommands[argv[0].to_sym].run(argv[1..-1])
      end.tap do |exitstatus|
        exit exitstatus
      end
    end
  end
end
