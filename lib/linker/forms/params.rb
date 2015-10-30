require 'linker/forms/attributes'

module Linker
  module Params
    extend ActiveSupport::Concern

    included do
      def params= params
        before_set_params(params)
        params.each do |param, value|
          if value.is_a?(Hash)
            table = param.gsub(%r{_attributes$}, '')
            # belongs_to attrs
            if map_belongs_to_associations.select{|c| c[:name] == table}.present?
              if value['id'].present?
                _get_main_model.send(table).update_attributes(value)
              else
                _get_main_model.send("build_#{table}", value)
              end

            # has_one attrs
            elsif search_has_one(table)
              if value['id'].present?
                _get_main_model.send(table).update_attributes(value)
              else
                _get_main_model.send("build_#{table}", value)
              end

            # has_many attrs
            else
              ids_to_remove = value.map{|c| c.last['id'] if c.last['id'].present? && c.last.key?('_remove') && c.last['_remove'] == '1' }.compact

              if ids_to_remove.present?
                r = search_has_many(table)
                r[:klass].constantize.send(:where, ["#{r[:klass].constantize.table_name}.id IN (?)", ids_to_remove]).destroy_all
                value.delete_if{|i, c| ids_to_remove.include?(c['id']) }
              end

              value.each do |c|
                if c.last['id'].present?
                  _get_main_model.send(table).find(c.last['id']).update_attributes(c.last.except('_remove'))
                else
                  _get_main_model.send(table).send(:build, c.last.except('_remove'))
                end
              end
            end
          elsif param.match(/_list$/)
            assoc = param.gsub(/_list$/, '')
            if r = search_has_one(assoc)
              final = value.present? ? r[:klass].constantize.send(:find, value) : nil
              _get_main_model.send("#{assoc}=", final)
            end
          else
            self.send("#{param}=", value)
          end
        end
      end

      # Saves main model with its associated records, with or without validation
      # (defaults to `:true`, with validation)
      #
      # @param validate [boolean] a boolean declaring if the form class must be validated.
      # @return [boolean] a boolean representing if the form class was validated (or no, if `validate` is `false`) and
      # saved successfully
      def save validate: true
        main_model = _get_main_model
        before_save

        if validate
          r = (self.valid? && main_model.save)
          after_save
        else
          r = main_model.save
          after_save
        end
        r
      end

      def before_set_params params
      end

      def before_save
      end

      def after_save
      end

    end

    private
      def _get_main_model
        main_model ||= self.send(self.class._main_model.underscore)
      end

      def search_has_one name
        s = @mapped_ho_assoc.detect{|c| c[:name] == name}
        s.present? && s
      end

      def search_has_many name
        s = @mapped_hm_assoc.detect{|c| c[:name] == name}
        s.present? && s
      end
  end
end