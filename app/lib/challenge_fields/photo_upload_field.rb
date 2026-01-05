# frozen_string_literal: true

module ChallengeFields  
  class PhotoUploadField < BaseField
    def check_answer
      true
    end

    def requires_photo?
      true
    end

    def max_photos
      template_config(:max_photos) || 1
    end

    def require_caption?
      template_config(:require_caption) || false
    end

    def points
      0
    end
  end
end
