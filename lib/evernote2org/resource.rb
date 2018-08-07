require 'base64'

module Evernote2org
  class Resource

    attr_accessor :doc, :id, :binary, :mime, :file_ext_name

    def initialize(doc)
      @doc = doc
      if recognition = @doc.css('recognition').first
        @id = Nokogiri::XML(recognition.content).css('recoIndex').first.attr('objID')
      end
      @mime = @doc.css('mime').first.content
      @file_ext_name = '.' + @mime.split('/').last
      @binary = Base64.decode64(@doc.css('data').first.content)
    end

    def export_to(out_dir)
      return unless @id
      File.open(File.join(out_dir, file_name), 'w') do |resource_file|
        resource_file.write(binary)
      end
    end

    def file_name
      @id + @file_ext_name
    end

    def to_img_tag(path, html_doc)
      img = Nokogiri::XML::Node.new('img', html_doc)
      img[:src] = File.join(path, file_name)
      img
    end
  end
end
