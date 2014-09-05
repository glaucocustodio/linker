require 'linker/forms/attributes'

module Linker
  module Params
    extend ActiveSupport::Concern

    included do
      def params= params
        # Delete all associated objects if there is nothing in params
        @mapped_hm_assoc.each do |c|
          _get_main_model.send(c[:tablelized_klass]).destroy_all if !params.key?("#{c[:tablelized_klass]}_attributes")
        end

        params.each do |param, value|
          table = param.gsub(%r{_attributes$}, '')

          if value.is_a?(Hash)
            # belongs_to attrs
            if map_belongs_to_associations.select{|c| c[:klass] == table.singularize.camelize}.present?
              if value['id'].present?
                _get_main_model.send(table).update_attributes(value)
              else
                _get_main_model.send("build_#{table}", value)
              end

            # has_one attrs
            elsif map_has_one_associations.select{|c| c[:klass] == table.camelize}.present?
              if value['id'].present?
                _get_main_model.send(table).update_attributes(value)
              else
                _get_main_model.send("#{table}=", table.camelize.constantize.new(value))
              end

            # has_many attrs
            else
              ids = value.map.with_index{|c,i| c.last['id'].present? ? c.last['id'] : nil }.compact
              _get_main_model.send(table).where(["#{table}.id NOT IN (?)", ids]).destroy_all if ids.present?

              value.each do |c|
                if c.last['id'].present?
                  _get_main_model.send(table).find(c.last['id']).update_attributes(c.last)
                else
                  _get_main_model.send(table) << table.singularize.camelize.constantize.new(c.last)
                end
              end
            end
          else
            self.send("#{param}=", value)
          end
        end
      end

      def save validate: true
        main_model = _get_main_model

        if validate
          self.valid? && main_model.save
        else
          main_model.save
        end
      end

    end

    private
      def _get_main_model
        main_model ||= self.send(self.class._main_model.underscore)
      end
  end
end