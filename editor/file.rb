module Pickaxe
  module Editor
    class File
      attr_accessor :path

      def initialize(path = nil)
        @path = path
      end

      def name
        if saved?
          ::File.basename @path
        else
          :new_file
        end
      end

      def new?
        not saved?
      end

      def saved?
        not @path.nil?
      end
    end
  end
end
