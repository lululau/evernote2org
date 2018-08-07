require 'evernote2org/enex'
require 'optparse'
require 'fileutils'

module Evernote2org
  module Cli
    class << self
      def start
        options = build_options!
        enex = Enex.parse(options[:input])
        FileUtils.mkdir_p(options[:output])
        enex.export_to(options[:output])
      end

      def build_options!
        options = {}
        OptionParser.new do |opts|
          opts.banner = "Usage: evernote2org -f [.enex file] -o [output.org]"

          opts.on("-fFILE", "--file=FILE", "input .enex file") do |f|
            options[:input] = f
          end

          opts.on("-oOUT", "--out=OUT", "output directory") do |o|
            options[:output] = o
          end
        end.parse!

        options
      end
    end
  end
end
