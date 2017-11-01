require 'optparse'

require "vidar/version"

module Vidar
  class Command
    def initialize(method)
      @method = method
      @kwargs = {}

      mount
    end

    def run(argv)
      args = @option_parser.parse(argv)
      # https://bugs.ruby-lang.org/issues/11860
      if @kwargs.empty?
        @method.call(*args)
      else
        @method.call(*args, **@kwargs)
      end
    end

    private

    def mount
      @option_parser = OptionParser.new

      @method.parameters.each do |type, name|
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
  end

  class CLI
    def initialize
      @subcommands = {}
    end

    def mount_subcommand(klass)
      instance = klass.new
      instance.public_methods(false).each do |method_name|
        @subcommands[method_name] = Command.new(instance.method(method_name))
      end
    end

    def run!(argv)
      command = @subcommands[argv[0].to_sym]
      exit command.run(argv[1..-1])
    end
  end
end
