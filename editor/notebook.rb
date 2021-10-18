require 'tk'
require_relative 'code_view'

module Pickaxe
  module Editor
    class Notebook < Ttk::Notebook
      def initialize(parent)
        super

        bind_keys
      end

      def add_code_view(file_path = nil)
        code_view = CodeView.new self, file_path
        add code_view, text: code_view.title
      end

      def bind_keys
        bind 'Button-2', method(:on_close_code_view)
      end

      def code_views
        tabs
      end

      def current_code_view
        current_code_view_index = index 'current'
        code_views[current_code_view_index]
      end

      def has_unsaved_changes?
        has_unsaved_changes = false
        code_views.each do |code_view|
          has_unsaved_changes = true if code_view.has_unsaved_changes?
        end
        has_unsaved_changes
      end

      def identify_tab(x, y)
        tk_send :identify, :tab, x, y
      end

      def on_close_code_view(event)
        code_view_index = identify_tab event.x, event.y
        unless code_view_index.empty?
          code_view = code_views[code_view_index.to_i]
          will_be_closed = true
          will_be_closed = code_view.ask_for_unsaved_changes if code_view.has_unsaved_changes?
          forget code_view_index if will_be_closed
        end
      end

      def save_current_code_view
        current_code_view.save
      end

      def save_current_code_view_as
        current_code_view.save_as
      end

      def save_unsaved_changes
        all_saved = true
        code_views.each do |code_view|
          saved = code_view.save
          all_saved = false unless saved
        end
        all_saved
      end
    end
  end
end
