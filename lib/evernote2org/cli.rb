require 'evernote2org/enex'
require 'fileutils'

module Evernote2org
  module Cli
    class << self
      def start
        enex = Enex.parse(ARGV[0])
        out_dir = ARGV[1]
        FileUtils.mkdir_p(out_dir)
        enex.export_to(out_dir)
      end
    end
  end
end
