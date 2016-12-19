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
      create_list_accessors_for(map_has_one_associations)
      create_list_accessors_for(map_has_and_belongs_to_many_associations)
      set_remove_accessor(map_has_many_associations)
    end

    def set_reader_for_main_model
      # Create attr reader for main model
      self.class.__send__(:attr_reader, @main_model.to_s.underscore)
    end

    def set_delegations
      # Delegate fields for main model
      filter_columns(@main_model).each do |c|
        delegate_attr(c, @main_model.to_s.underscore)
      end

      [map_has_one_associations, map_belongs_to_associations].each do |rgroup|
        rgroup.each do |c|
          c[:columns].each do |cc|
            # ap "delegating #{cc} and #{cc}= for #{c[:name]}__#{cc}"
            self.class.__send__(:delegate, cc, "#{cc}=", to: c[:name].underscore.to_sym, prefix: "#{c[:name]}_")
          end
        end
      end
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

    def get_has_and_belongs_to_many_associations
      @habtm_assoc ||= @main_model.reflect_on_all_associations(:has_and_belongs_to_many)
    end

    def filter_columns(model)
      f = model.columns.map(&:name)
                       .delete_if { |cn| USELESS_COLUMNS_REGEX.match(cn) }
      # Get Paperclip attachments
      begin
        f = Paperclip::AttachmentRegistry.names_for(model).inject(f) do |t, c|
          t << c.to_s
        end
      rescue
      end
      f
    end

    def delegate_attr(att, class_to)
      # ap "delegating #{att} and #{att}= for #{class_to.underscore.pluralize.to_sym}"
      self.class.__send__(:delegate, att, "#{att}=", to: class_to.underscore.to_sym)
    end

    # Create required methods to use `fields_for`
    def set_fields_for_methods(assoc_set, singular = false)
      assoc_set.each do |c|
        # ap "creating method #{c[:name]}"
        self.class.send(:define_method, c[:name]) do
          assocs = instance_variable_get("@#{get_main_model.to_s.underscore}")
          .send(c[:name])

          neww = singular ? c[:klass].constantize.new : [c[:klass].constantize.new] * 2

          if singular
            (assocs.present? && assocs) || neww
          else
            (assocs.map { |c| c }.present? && assocs.map { |c| c }) || neww
          end
        end

        # ap "creating method #{c[:name]}_attributes="
        self.class.send(:define_method, "#{c[:name]}_attributes=") do |attributes|
        end
      end
    end

    def create_list_accessors_for(assoc_set)
      assoc_set.each do |c|
        self.class.__send__(:attr_accessor, "#{c[:name]}_list")
      end
    end

    def set_remove_accessor(assoc_set)
      assoc_set.each do |c|
        # ap "creating attr_accessor :_remove para #{c[:klass]}"
        c[:klass].constantize.class_eval { attr_accessor :_remove }
      end
    end

    def map_associations(assoc)
      assoc.inject([]) do |t, c|
        t << {
          name: c.name.to_s,
          klass: c.klass.name,
          # delete_if remove useless attrs
          columns: filter_columns(c.klass)
        }
      end
    end

    def map_has_many_associations
      # Create an array with associated classes names and attrs
      @mapped_hm_assoc ||= map_associations(get_has_many_associations)
    end

    def map_belongs_to_associations
      # Create an array with associated classes names and attrs
      @mapped_bt_assoc ||= map_associations(get_belongs_to_associations)
    end

    def map_has_one_associations
      # Create an array with associated classes names and attrs
      @mapped_ho_assoc ||= map_associations(get_has_one_associations)
    end

    def map_has_and_belongs_to_many_associations
      # Create an array with associated classes names and attrs
      @mapped_habtm_assoc ||= map_associations(get_has_and_belongs_to_many_associations)
    end
  end
end
