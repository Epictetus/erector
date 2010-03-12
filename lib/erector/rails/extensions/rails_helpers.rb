module Erector
  module Rails
    module Helpers
      # Set up URL helpers so that both helpers.users_url and users_url can be called.
      include ActionController::UrlWriter

      def url_for(*args)
        helpers.url_for(*args)
      end

      # Wrappers for rails helpers that would always be used in ERB via <%= %>.
      # Erector needs to manually output their result.
      def self.def_simple_rails_helper(method_name)
        module_eval(<<-METHOD_DEF, __FILE__, __LINE__)
          def #{method_name}!(*args, &block)
            text! #{method_name}(*args, &block)
          end

          def #{method_name}(*args, &block)
            helpers.#{method_name}(*args, &block)
          end
        METHOD_DEF
      end

      [
        # UrlHelper
        :link_to,
        :button_to,
        :link_to_unless_current,
        :link_to_unless,
        :link_to_if,
        :mail_to,

        # JavaScriptHelper
        :link_to_function,
        :button_to_function,

        # FormTagHelper
        :form_tag,
        :select_tag,
        :text_field_tag,
        :label_tag,
        :hidden_field_tag,
        :file_field_tag,
        :password_field_tag,
        :text_area_tag,
        :check_box_tag,
        :radio_button_tag,
        :submit_tag,
        :image_submit_tag,
        :field_set_tag,

        # FormHelper
        :form_for,
        :text_field,
        :password_field,
        :hidden_field,
        :file_field,
        :text_area,
        :check_box,
        :radio_button,

        # ActiveRecordHelper
        :error_message_on,
        :error_messages_for,

        # AssetTagHelper
        :auto_discovery_link_tag,
        :javascript_include_tag,
        :stylesheet_link_tag,
        :image_tag,

        # ScriptaculousHelper
        :sortable_element,
        :sortable_element_js,
        :text_field_with_auto_complete,
        :draggable_element,
        :drop_receiving_element,

        # PrototypeHelper
        :link_to_remote,
        :button_to_remote,
        :periodically_call_remote,
        :form_remote_tag,
        :submit_to_remote,
        :update_page_tag
      ].each do |method_name|
        def_simple_rails_helper(method_name)
      end

      # Wrappers for rails helpers that concat directly to the output
      # buffer if given a block, and return a string otherwise. Erector
      # needs to manually output their result in the latter case.
      def self.def_block_rails_helper(method_name)
        module_eval(<<-METHOD_DEF, __FILE__, __LINE__)
          def #{method_name}(*args, &block)
            if block_given?
              helpers.#{method_name}(*args, &block)
            else
              text helpers.#{method_name}(*args, &block)
            end
          end
        METHOD_DEF
      end

      [:link_to,
       :form_tag,
       :field_set_tag,
       :form_remote_tag,
       :javascript_tag].each do |method_name|
        def_block_rails_helper(method_name)
      end

      def render(*args, &block)
        captured = helpers.capture do
          helpers.concat(helpers.render(*args, &block))
          helpers.output_buffer.to_s
        end
        text!(captured)
      end

      def form_for(record_or_name_or_array, *args, &proc)
        options = args.extract_options!
        options[:builder] ||= ::Erector::RailsFormBuilder
        args.push(options)
        helpers.form_for(record_or_name_or_array, *args, &proc)
      end

      def fields_for(record_or_name_or_array, *args, &proc)
        options = args.extract_options!
        options[:builder] ||= ::Erector::RailsFormBuilder
        args.push(options)
        helpers.fields_for(record_or_name_or_array, *args, &proc)
      end
      
      def flash
        helpers.controller.send(:flash)
      end

      def session
        helpers.controller.session
      end
    end

    Erector::Widget.send :include, Helpers
  end
end
