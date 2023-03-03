module GovukPublishingComponents
  module Presenters
    class ComponentWrapperHelper
      def initialize(options)
        @options = options

        check_id_is_valid(@options[:id]) if @options.include?(:id)
        check_classes_are_valid(@options[:classes]) if @options.include?(:classes)
        check_aria_is_valid(@options[:aria]) if @options.include?(:aria)
        check_role_is_valid(@options[:role]) if @options.include?(:role)
      end

      def all_attributes
        attributes = {}

        attributes[:id] = @options[:id] if @options[:id]
        attributes[:data] = @options[:data_attributes] if @options[:data_attributes]
        attributes[:aria] = @options[:aria] if @options[:aria]
        attributes[:class] = @options[:classes] if @options[:classes]
        attributes[:role] = @options[:role] if @options[:role]

        attributes
      end

      def set_id(id)
        check_id_is_valid(id)
        @options[:id] = id
      end

      def add_class(classes)
        check_classes_are_valid(classes)
        extend_string(:classes, classes)
      end

      def add_data_attribute(attributes)
        extend_object(:data_attributes, attributes)
      end

      def add_aria_attribute(attributes)
        check_aria_is_valid(attributes)
        extend_object(:aria, attributes)
      end

      def add_role(role)
        check_role_is_valid(role)
        extend_string(:role, role)
      end

    private

      def check_id_is_valid(id)
        raise(ArgumentError, "Id cannot start with a number or contain whitespace and can only contain letters, digits, `_` and `-`") unless /^[a-zA-Z][\w:-]*$/.match?(id)
      end

      def check_classes_are_valid(classes)
        classes = classes.split(" ")
        unless classes.all? { |c| c.start_with?("js-", "gem-c-", "govuk-", "brand--") }
          raise(ArgumentError, "Passed classes must be prefixed with `js-`")
        end
      end

      def check_aria_is_valid(attributes)
        arias = %w[activedescendant atomic autocomplete busy checked colcount colindex colspan controls current describedby description details disabled dropeffect errormessage expanded flowto grabbed haspopup hidden invalid keyshortcuts label labelledby level live modal multiline multiselectable orientation owns placeholder posinset pressed readonly relevant required roledescription rowcount rowindex rowspan selected setsize sort valuemax valuemin valuenow valuetext]

        unless attributes.all? { |key, _value| arias.include? key.to_s }
          raise(ArgumentError, "Aria attribute is not recognised")
        end
      end

      def check_role_is_valid(role)
        roles = %w[alert alertdialog application article associationlist associationlistitemkey associationlistitemvalue banner blockquote caption cell code columnheader combobox complementary contentinfo definition deletion dialog directory document emphasis feed figure form group heading img insertion list listitem log main marquee math menu menubar meter navigation none note paragraph presentation region row rowgroup rowheader scrollbar search searchbox separator separator slider spinbutton status strong subscript superscript switch tab table tablist tabpanel term time timer toolbar tooltip tree treegrid treeitem]
        role = role.split(" ") # can have more than one role
        unless role.all? { |r| roles.include? r }
          raise(ArgumentError, "Role attribute is not recognised")
        end
      end

      def extend_string(option, string)
        ((@options[option] ||= "") << " #{string}").strip!
      end

      def extend_object(option, object)
        @options[option] ||= {}
        object.each_key do |key|
          @options[option][key] =
            if @options[option].key?(key)
              "#{@options[option][key]} #{object[key]}"
            else
              object[key]
            end
        end
      end
    end
  end
end
