# frozen_string_literal: true

module ChallengeFields
  module FormFields
    class BaseFormField < DynamicFields::Fields::FormField
      form_attribute :answer, :string

      def partial_name
        type.to_s
      end

      def admin_partial_path
        "admin/challenges/fields/#{partial_name}_form"
      end

      def attempt_partial_path
        "attempts/fields/#{partial_name}_form"
      end
    end
  end
end
