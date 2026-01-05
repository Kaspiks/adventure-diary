# frozen_string_literal: true

module ChallengeFields
  module FormFields
    class PhotoUploadFormField < BaseFormField
      attr_accessor :photos, :captions

      def max_photos
        model_field.max_photos
      end

      def require_caption?
        model_field.require_caption?
      end

      def permitted_attributes
        [:answer, photos: [], captions: []]
      end
    end
  end
end
