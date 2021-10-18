require 'tk'
require_relative 'file'

module Pickaxe
  module Explorer
    class Treeview < Ttk::Treeview
      def initialize(parent, open_file)
        super parent

        self.show = :tree

        @open_file = open_file

        create_context_menu

        bind_keys
      end

      def bind_keys
        bind 'Double-Button-1', method(:on_open_file)
        bind 'Button-3', method(:on_open_context_menu)
      end

      def create_context_menu
        @folder_menu = Tk::Menu.new self, tearoff: false
        @folder_menu.add_command label: 'New file', command: method(:on_new_file)
        @folder_menu.add_command label: 'New folder', command: method(:on_new_folder)
        @folder_menu.add_separator
        @folder_menu.add_command label: 'Rename', command: method(:on_rename)
        @folder_menu.add_separator
        @folder_menu.add_command label: 'Delete', command: method(:on_delete)

        @file_menu = Tk::Menu.new self, tearoff: false
        @file_menu.add_command label: 'New file', command: method(:on_new_file)
        @file_menu.add_command label: 'New folder', command: method(:on_new_folder)
        @file_menu.add_separator
        @file_menu.add_command label: 'Rename', command: method(:on_rename)
        @file_menu.add_separator
        @file_menu.add_command label: 'Delete', command: method(:on_delete)

        @empty_area_menu = Tk::Menu.new self, tearoff: false
        @empty_area_menu.add_command label: 'New file', command: method(:on_new_file)
        @empty_area_menu.add_command label: 'New folder', command: method(:on_new_folder)
      end

      def on_new_file
        # Learn name of the new file
        enter_new_file_name_dialog = Tk::Toplevel.new
        enter_new_file_name_dialog.title = 'New file'
        entry_frame = Ttk::Frame.new enter_new_file_name_dialog
        entry_frame.pack side: :top
        label = Ttk::Label.new entry_frame, text: 'New file name:'
        label.pack side: :left
        entry = Ttk::Entry.new entry_frame
        entry.pack side: :left
        buttons_frame = Ttk::Frame.new enter_new_file_name_dialog
        buttons_frame.pack side: :top
        ok_button = Ttk::Button.new buttons_frame, text: 'OK'
        ok_button.pack side: :left
        cancel_button = Ttk::Button.new buttons_frame, text: 'Cancel'
        cancel_button.pack side: :left

        if @context_item
          context_item_file_path = @context_item.id
          if ::File.directory? context_item_file_path
          else
          end
        else
        end
      end

      def on_new_folder
        if @context_item
          context_item_file_path = @context_item.id
          if ::File.directory? context_item_file_path
          else
          end
        else
        end
      end

      def on_rename
        if @context_item
          context_item_file_path = @context_item.id
          if ::File.directory? context_item_file_path
          else
          end
        end
      end

      def on_delete
        if @context_item
          context_item_file_path = @context_item.id
          if ::File.directory? context_item_file_path
          else
          end
        end
      end

      def on_open_context_menu(event)
        @context_item = identify_item event.x, event.y
        if @context_item
          context_item_file_path = @context_item.id
          if ::File.directory? context_item_file_path
            @folder_menu.post event.root_x, event.root_y
          else
            @file_menu.post event.root_x, event.root_y
          end
        else
          @empty_area_menu.post event.root_x, event.root_y
        end
      end

      def on_open_file(event)
        item = identify_item event.x, event.y
        if item
          item_file_path = item.id
          if ::File.file? item_file_path
            @open_file.call item_file_path
          end
        end
      end

      def open_folder(folder_path)
        files = Dir.glob '**/*', base: folder_path
        files.map! do |relative_file_path|
          file_path = ::File.join folder_path, relative_file_path
          File.new file_path
        end
        # Sort by names, case-insensitive
        files.sort_by! do |file|
          file.name.downcase
        end
        # Put directories first
        files.sort! do |first, second|
          first_sort_value = first.folder? ? 0 : 1
          second_sort_value = second.folder? ? 0 : 1

          first_sort_value - second_sort_value
        end

        files.each do |file|
          parent = ::File.identical?(file.folder_path, folder_path) ? '' : file.folder_path

          insert parent, :end, id: file.path, text: file.name
        end
      end
    end
  end
end
