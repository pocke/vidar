require 'optparse'

require "vidar/version"

module Vidar
  class CLI
    def initialize
      @commands = {}
    end

    def mount(klass)
      @class = klass
      klass.public_instance_methods(false).each do |method_name|
        OptionParser.new.tap do |opt|
          @commands[method_name] = {
            opt: opt,
            args: {},
          }

          method = klass.public_instance_method(method_name)
          method.parameters.each do |type, name|
            case type
            when :req, :opt, :rest
              next
            when :keyreq, :key
              optname = name.size == 1 ? "-#{name}" : "--#{name.to_s.gsub('_', '-')}"
              optname << " VALUE"
              opt.on(optname) {|value| @commands[method_name][:args][name] = value}
            when :keyrest, :block
              raise "#{type} is not supported type!"
            else
              raise "#{type} is unknwon parameter type!"
            end
          end
        end
      end
    end

    def run!(argv)
      command = @commands[argv[0].to_sym]
      args = command[:opt].parse(argv[1..-1])
      # https://bugs.ruby-lang.org/issues/11860
      keywords = command[:args]
      if keywords.empty?
        exit @class.new.public_send(argv[0].to_sym, *args)
      else
        exit @class.new.public_send(argv[0].to_sym, *args, **keywords)
      end
    end
  end
end
