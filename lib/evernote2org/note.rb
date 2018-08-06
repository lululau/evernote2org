require 'nokogiri'
require 'fileutils'
require 'active_support/all'
require 'time'
require 'pandoc-ruby'
require 'evernote2org/resource'

module Evernote2org
  class Note
    attr_accessor :doc, :title, :content, :resources, :author, :url, :created_at

    def initialize(content)
      @doc = content
      @title = @doc.css('title').first.content
      @resources = @doc.css('resource').map { |res| Resource.new(res) }
      @content = parse_content
      @author = @doc.css('author').first&.content
      @url = @doc.css('source_url').first&.content
      @created_at = Time.strptime(@doc.css('created').first.content, '%Y%m%dT%H%M%SZ')
    end

    def export_to(out_dir)
      if @resources.present?
        resources_dir = make_resources_dir(out_dir)
        export_resources(resources_dir)
      end
      export_content(out_dir)
    end

    def export_content(out_dir)
      File.open(File.join(out_dir, consistent_file_name + '.org'), 'w') do |out_file|
        out_file.write(PandocRuby.new(@content.to_s, from: :html, to: :org).convert)
      end
    end

    def export_resources(resources_dir)
      @resources.each do |resource|
        resource.export_to(resources_dir)
      end
    end

    def consistent_file_name
      @title.gsub(/[[:punct:][:space:]]/, '_')
    end

    def make_resources_dir(out_dir)
      dir = File.join(out_dir, export_dir_name)
      FileUtils.mkdir_p(dir)
      dir
    end

    def export_dir_name
      consistent_file_name
    end

    def parse_content
      content = Nokogiri::XML(@doc.css('content').first.content).css('en-note').first
      @resources.each do |resource|
        img_tag = resource.to_img_tag(export_dir_name, content)
        en_media = content.css("en-media[hash=\"#{resource.id}\"]").first
        en_media.add_next_sibling(img_tag)
        en_media.remove
      end
      content
    end
  end
end
