require 'ripper'
require 'tk'
require_relative 'file'

module Pickaxe
  module Editor
    class CodeView < Tk::Text
      def initialize(parent, file_path = nil)
        super parent

        self.undo = true
        self.wrap = :none

        @file = File.new file_path
        @has_unsaved_changes = false
        @is_first_change = false

        unless @file.new?
          file_text = ::File.read @file.path
          insert :end, file_text
          @is_first_change = true
          # Reset undo and redo stacks so initial file text cannot be undone
          edit_reset
        end

        bind_virtual_events
      end

      def ask_for_unsaved_changes
        title = 'Unsaved Changes'
        message = 'There are unsaved changes'
        detail = 'Do you want to save?'
        ask_result = Tk.messageBox(
          type: :yesnocancel,
          default: :yes,
          icon: :warning,
          title: title,
          message: message,
          detail: detail
        )
        final_result = false
        final_result = false if ask_result == 'cancel'
        final_result = true if ask_result == 'no'
        if ask_result == 'yes'
          final_result = save
        end
        final_result
      end

      def bind_virtual_events
        bind '<Modified>', method(:on_modified)
      end

      def configure_highlight_tags
        tag_configure :on_backtick, foreground: '#F00'
        tag_configure :on_comment, foreground: '#0FF'
        tag_configure :on_const, foreground: '#00F'
        tag_configure :on_embexpr_beg, foreground: '#F00'
        tag_configure :on_embexpr_end, foreground: '#F00'
        tag_configure :on_embvar, foreground: '#F00'
        tag_configure :on_float, foreground: '#F0F'
        tag_configure :on_gvar, foreground: '#0F0'
        tag_configure :on_ident, foreground: '#00F'
        tag_configure :on_imaginary, foreground: '#00F'
        tag_configure :on_int, foreground: '#00F'
        tag_configure :on_kw, foreground: '#F0F'
        tag_configure :on_label, foreground: '#F0F'
        tag_configure :on_label_end, foreground: '#F00'
        tag_configure :on_rational, foreground: '#00F'
        tag_configure :on_regexp_beg, foreground: '#F00'
        tag_configure :on_regexp_end, foreground: '#F00'
        tag_configure :on_symbeg, foreground: '#0F0'
        tag_configure :on_symbols_beg, foreground: '#F00'
        tag_configure :on_tstring_beg, foreground: '#F00'
        tag_configure :on_tstring_content, foreground: '#F00'
        tag_configure :on_tstring_end, foreground: '#F00'
        tag_configure :on_words_beg, foreground: '#F00'
      end

      def delete_all_tags
        all_tags = tag_names
        tag_delete *all_tags
      end

      def has_unsaved_changes?
        @has_unsaved_changes
      end

      def highlight
        tokens = Ripper.lex(get_all)
        tokens.each do |token|
          higlight_this_token = true
          tag_name = token[1]
          # Highlight only module, class or method names for identifiers
          if tag_name == :on_ident && token[3] != Ripper::EXPR_ENDFN
            higlight_this_token = false
          end
          if higlight_this_token
            line = token[0][0]
            column = token[0][1]
            token_length = token[2].length
            index1 = "#{line}.#{column}"
            index2 = "#{line}.#{column}+#{token_length}chars"
            tag_add tag_name, index1, index2
          end
        end
      end

      def get_all
        get('1.0', :end)
      end

      def get_all_wo_eol
        get_all[...-1]
      end

      def on_modified
        if modified?
          # Highlight
          delete_all_tags
          configure_highlight_tags
          highlight

          unless @is_first_change
            @has_unsaved_changes = true
          else
            @is_first_change = false
          end
          self.modified = false
        end
      end

      def save
        if @file.saved?
          code_view_text = get_all_wo_eol
          ::File.write @file.path, code_view_text

          @has_unsaved_changes = false

          true
        else
          save_as
        end
      end

      def save_as
        file_path = Tk.getSaveFile
        unless file_path.empty?
          @file.path = file_path
          save
        end
      end

      def title
        @file.name
      end
    end
  end
end
