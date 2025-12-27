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





