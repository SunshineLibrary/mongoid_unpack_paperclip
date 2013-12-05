# encoding: UTF-8

module ::Mongoid
  module UnpackPaperclip
    extend ActiveSupport::Concern

    included do
      field :unpack_paperclip_errors, type: Array, default: []
    end

    def unpack_paperclip &blk
      return false if not blk
      item = self

      # 1. unpack
      # 1.1 fetch paperclip object
      paperclip_regexp = /_([a-z_]+)_post_process_callbacks/
      paperclip_method = item.methods.detect {|m| m.match(paperclip_regexp) }.to_s.match(paperclip_regexp)[1]
      return false if not File.exists? item.send(paperclip_method).path
      paperclip_path   = item.send(paperclip_method).path
      FileUtils.chdir  File.dirname(paperclip_path)
      extract_path     = File.basename(paperclip_path).split('.')[0]
      # 1.2 unpack zip
      pre_uncompress_command = case extname = File.extname(paperclip_path)
      when ".zip"
        "unzip -oqqd "
      when ".7z"
        "7z x -yo"
      else
        # return false directly
        return "#{extname} is invalid"
      end
      root_dir = File.join(Dir.pwd, extract_path)

      item.unpack_paperclip_errors = []
      item.save validate: false
      result = nil

      begin
        system "#{pre_uncompress_command}#{extract_path} #{paperclip_path}"
        # 1.3 look dir
        FileUtils.chdir extract_path

        # 2. yield process
        result = yield Dir.pwd

      rescue => e
        item.unpack_paperclip_errors = e.backtrace.push(e).map(&:inspect)
        item.save validate: false
      end

      # 3. clean files
      FileUtils.rm_rf root_dir
      FileUtils.chdir Rails.root

      return result
    end

  end
end
