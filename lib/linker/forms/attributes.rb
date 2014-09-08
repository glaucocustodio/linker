require 'linker/forms/configuration_methods'

module Linker
  module Attributes
    extend ActiveSupport::Concern
    include Linker::ConfigurationMethods

    USELESS_COLUMNS_REGEX  = %r{^(updated_at|created_at)$}

    def get_main_model
      @main_model ||= self.class._main_model.constantize
    end

    def prepare_attrs
      get_main_model
      set_reader_for_main_model
      set_delegations
      set_fields_for_methods(map_has_many_associations)
      set_fields_for_methods(map_belongs_to_associations, true)
      set_fields_for_methods(map_has_one_associations, true)
    end

    def set_reader_for_main_model
      #ap "criando reader for main model #{@main_model.to_s.underscore}"
      # Create attr reader for main model
      self.class.__send__(:attr_reader, @main_model.to_s.underscore)
    end   

    def set_delegations
      # Delegate fields for main model
      filter_columns(@main_model).each{|c| delegate_attr(c, @main_model.to_s.underscore) }
    end

    private
      def get_has_many_associations
        @hm_assoc ||= @main_model.reflect_on_all_associations(:has_many)
      end

      def get_has_one_associations
        @ho_assoc ||= @main_model.reflect_on_all_associations(:has_one)
      end

      def get_belongs_to_associations
        @bt_assoc ||= @main_model.reflect_on_all_associations(:belongs_to)
      end

      def filter_columns model
        f = model.columns.map(&:name)
                         .delete_if{|cn| USELESS_COLUMNS_REGEX.match(cn) }
        # Get Paperclip attachments
        begin
          f = Paperclip::AttachmentRegistry.names_for(model).inject(f) do |t, c|
            t << c.to_s
          end
        rescue
        end
        f
      end

      def delegate_attr att, class_to
        #ap "delegando #{att} e #{att}= para #{class_to.underscore.pluralize.to_sym}"
        self.class.__send__(:delegate, att, "#{att}=", to: class_to.underscore.to_sym)
      end

      # Create required methods to use `fields_for`
      def set_fields_for_methods assoc_set, singular = false
        assoc_set.each do |c|
          #ap "criando método #{c[:name]}"
          self.class.send(:define_method, c[:name]) do
            assocs = instance_variable_get("@#{get_main_model.to_s.underscore}")
            .send(c[:name])

            neww = singular ? c[:klass].constantize.new : [c[:klass].constantize.new] * 2

            if singular
              (assocs.present? && assocs) || neww
            else
              (assocs.map{|c| c}.present? && assocs.map{|c| c}) || neww
            end
          end

          #ap "criando método #{c[:name]}_attributes="
          self.class.send(:define_method, "#{c[:name]}_attributes=") do |attributes|
          end
        end
      end

      def map_associations assoc
        assoc.inject([]) do |t, c| 
          t << {
            name: c.name.to_s, 
            klass: c.klass.name,
            # delete_if remove useless attrs
            columns:       filter_columns(c.klass)
          }
        end
      end

      def map_has_many_associations
        # Create an array with associated classes names and attrs
        @mapped_hm_assoc ||= map_associations(get_has_many_associations)
        @mapped_hm_assoc
      end

      def map_belongs_to_associations
        # Create an array with associated classes names and attrs
        @mapped_bt_assoc ||= map_associations(get_belongs_to_associations)
        @mapped_bt_assoc
      end

      def map_has_one_associations
        # Create an array with associated classes names and attrs
        @mapped_ho_assoc ||= map_associations(get_has_one_associations)
        @mapped_ho_assoc
      end
  end
end