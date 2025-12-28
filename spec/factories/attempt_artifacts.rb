# frozen_string_literal: true

FactoryBot.define do
  factory :attempt_artifact do
    kind { "photo" }
    metadata { {} }
    field_id { nil }

    association :challenge_attempt

    after(:build) do |artifact|
      artifact.file.attach(
        io: StringIO.new("fake image content"),
        filename: "test_photo.jpg",
        content_type: "image/jpeg"
      )
    end

    trait :photo do
      kind { "photo" }
    end

    trait :video do
      kind { "video" }
      after(:build) do |artifact|
        artifact.file.attach(
          io: StringIO.new("fake video content"),
          filename: "test_video.mp4",
          content_type: "video/mp4"
        )
      end
    end

    trait :for_field do
      transient do
        target_field_id { SecureRandom.uuid }
      end

      field_id { target_field_id }
    end
  end
end

# == Schema Information
#
# Table name: attempt_artifacts
#
#  id                   :bigint           not null, primary key
#  kind                 :string(50)       not null
#  metadata             :json
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  challenge_attempt_id :integer          not null
#  field_id             :string(255)
#
# Indexes
#
#  index_attempt_artifacts_on_challenge_attempt_id               (challenge_attempt_id)
#  index_attempt_artifacts_on_challenge_attempt_id_and_field_id  (challenge_attempt_id,field_id)
#  index_attempt_artifacts_on_challenge_attempt_id_and_kind      (challenge_attempt_id,kind)
#
# Foreign Keys
#
#  fk_rails_...  (challenge_attempt_id => challenge_attempts.id)
#





