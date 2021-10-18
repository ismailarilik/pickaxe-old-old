module Pickaxe
  module Explorer
    class File
      attr_accessor :path

      def initialize(path)
        @path = path
      end

      def name
        ::File.basename @path
      end

      def folder?
        ::File.directory? @path
      end

      def folder_path
        ::File.dirname @path
      end
    end
  end
end