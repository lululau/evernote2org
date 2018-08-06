require 'nokogiri'
require 'evernote2org/note'

module Evernote2org
  class Enex
    attr_accessor :path, :notes, :doc

    def initialize(path)
      @path = path
      @notes = []
    end

    def parse!
      File.open(@path) do |file|
        @doc = Nokogiri::XML(file)
        @notes = @doc.css("note").map do |note_content|
          Note.new(note_content)
        end
      end

      self
    end

    def export_to(out_dir)
      @notes.each { |note| note.export_to(out_dir) }
    end

    class << self
      def parse(path)
        new(path).parse!
      end
    end
  end
end
