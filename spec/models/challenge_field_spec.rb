# frozen_string_literal: true

require "rails_helper"

RSpec.describe ChallengeField, type: :model do
  describe "#check_answer" do
    describe "text_input" do
      let(:field) do
        described_class.new(
          type: "text_input",
          required: true,
          correct_answer: "Paris"
        )
      end

      it "returns true for correct answer (case insensitive)" do
        expect(field.check_answer("Paris")).to be true
        expect(field.check_answer("paris")).to be true
        expect(field.check_answer("PARIS")).to be true
      end

      it "returns true with whitespace" do
        expect(field.check_answer("  Paris  ")).to be true
      end

      it "returns false for wrong answer" do
        expect(field.check_answer("London")).to be false
      end
    end

    describe "hidden_letter" do
      context "case insensitive" do
        let(:field) do
          described_class.new(
            type: "hidden_letter",
            required: true,
            correct_answer: "KEY",
            case_sensitive: false
          )
        end

        it "returns true for correct answer (any case)" do
          expect(field.check_answer("KEY")).to be true
          expect(field.check_answer("key")).to be true
          expect(field.check_answer("Key")).to be true
        end
      end

      context "case sensitive" do
        let(:field) do
          described_class.new(
            type: "hidden_letter",
            required: true,
            correct_answer: "KEY",
            case_sensitive: true
          )
        end

        it "returns true only for exact match" do
          expect(field.check_answer("KEY")).to be true
          expect(field.check_answer("key")).to be false
          expect(field.check_answer("Key")).to be false
        end
      end
    end

    describe "single_choice" do
      let(:field) do
        described_class.new(
          type: "single_choice",
          required: true,
          options: %w[A B C D],
          correct_answer: "B"
        )
      end

      it "returns true for correct option" do
        expect(field.check_answer("B")).to be true
      end

      it "returns false for wrong option" do
        expect(field.check_answer("A")).to be false
        expect(field.check_answer("C")).to be false
      end
    end

    describe "multiple_choice" do
      let(:field) do
        described_class.new(
          type: "multiple_choice",
          required: true,
          options: %w[A B C D],
          correct_answers: %w[A C]
        )
      end

      it "returns true for all correct options" do
        expect(field.check_answer(%w[A C])).to be true
        expect(field.check_answer(%w[C A])).to be true # order doesn't matter
      end

      it "returns false for partial match" do
        expect(field.check_answer(["A"])).to be false
      end

      it "returns false for extra options" do
        expect(field.check_answer(%w[A B C])).to be false
      end

      it "returns false for wrong options" do
        expect(field.check_answer(%w[B D])).to be false
      end
    end

    describe "photo_upload" do
      let(:field) do
        described_class.new(
          type: "photo_upload",
          required: true
        )
      end

      it "returns true if response present" do
        expect(field.check_answer("photo.jpg")).to be true
      end

      it "returns false if response blank" do
        expect(field.check_answer("")).to be false
        expect(field.check_answer(nil)).to be false
      end
    end

    describe "optional fields" do
      let(:field) do
        described_class.new(
          type: "text_input",
          required: false,
          correct_answer: "answer"
        )
      end

      it "returns true for blank response when not required" do
        expect(field.check_answer("")).to be true
        expect(field.check_answer(nil)).to be true
      end
    end
  end

  describe "type checkers" do
    it "#text_input? returns true for text_input" do
      field = described_class.new(type: "text_input")
      expect(field.text_input?).to be true
      expect(field.single_choice?).to be false
    end

    it "#single_choice? returns true for single_choice" do
      field = described_class.new(type: "single_choice")
      expect(field.single_choice?).to be true
    end

    it "#multiple_choice? returns true for multiple_choice" do
      field = described_class.new(type: "multiple_choice")
      expect(field.multiple_choice?).to be true
    end

    it "#photo_upload? returns true for photo_upload" do
      field = described_class.new(type: "photo_upload")
      expect(field.photo_upload?).to be true
    end

    it "#hidden_letter? returns true for hidden_letter" do
      field = described_class.new(type: "hidden_letter")
      expect(field.hidden_letter?).to be true
    end
  end

  describe "#to_h" do
    let(:field) do
      described_class.new(
        id: "test-id",
        type: "text_input",
        label: "Question",
        points: 10
      )
    end

    it "returns hash representation" do
      hash = field.to_h
      expect(hash[:id]).to eq("test-id")
      expect(hash[:type]).to eq("text_input")
      expect(hash[:label]).to eq("Question")
      expect(hash[:points]).to eq(10)
    end
  end
end

