require_relative 'application_window'

module Pickaxe
  class Application
    def initialize
      @application_window = ApplicationWindow.new
    end

    def start
      @application_window.mainloop
    end
  end
end
