# frozen_string_literal: true

module Admin
  class ChallengesController < BaseController
    include ChallengeFieldsHelper
    before_action :set_challenge, only: [:show, :edit, :update, :destroy, :attempts]

    def index
      @presenter = build_index_presenter
    end

    def show
      authorize @challenge
      @presenter = Admin::Challenges::ShowPresenter.new(challenge: @challenge)
    end

    def new
      challenge = Challenge.new
      form = build_form(challenge)
      @presenter = FormPresenter.new(form: form)
    end

    def create
      challenge = Challenge.new(creator_user: current_user)
      form = build_form(challenge)

      if form.create(create_params)
        redirect_to admin_challenge_path(challenge), notice: t(".success")
      else
        @presenter = FormPresenter.new(form: form)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @challenge
      form = build_form(@challenge)
      @presenter = FormPresenter.new(form: form)
    end

    def update
      authorize @challenge
      form = build_form(@challenge)

      if form.update(update_params)
        redirect_to admin_challenge_path(@challenge), notice: t(".success")
      else
        @presenter = FormPresenter.new(form: form)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @challenge
      @challenge.destroy
      redirect_to admin_challenges_path, notice: t(".success")
    end

    def attempts
      authorize @challenge, :review_attempts?
      @presenter = Admin::Challenges::AttemptsPresenter.new(
        challenge: @challenge,
        attempts: @challenge.challenge_attempts.includes(:user, :attempt_status).ordered
      )
    end

    def field_template
      field_type = params[:field_type]
      index = params[:index].to_i
      
      return head :unprocessable_entity unless ChallengeFields.valid_type?(field_type)
      
      # Create a temporary field object for rendering
      field = ChallengeField.new(type: field_type)
      form = build_form(Challenge.new)
      
      render partial: 'admin/challenges/field_form',
             locals: { form: form, field: field, index: index },
             layout: false
    end

    private

    def set_challenge
      @challenge = Challenge.find(params[:id])
    end

    def build_index_presenter
      search_form = Admin::Challenges::SearchForm.new(search_form_params)
      challenges = Admin::Challenges::SearchService.new(search_form: search_form, current_user: current_user).call

      Admin::Challenges::IndexPresenter.new(search_form: search_form, challenges: challenges)
    end

    def build_form(challenge)
      Admin::Challenges::Form.new(challenge)
    end

    def create_params
      # Permit all nested fields_config parameters
      permitted = params.require(:admin_challenges_form).permit(
        :title,
        :description,
        :location_id,
        :challenge_type_id,
        :difficulty_level_id,
        :award_point_level_id,
        :is_active,
        fields_config: [
          :id, :type, :label, :instructions, :required, :points,
          :correct_answer, :image_url, :display_text, :number_of_blanks,
          :case_sensitive, :hint, :max_photos, :require_caption,
          options: [], correct_answers: []
        ]
      )
      
      # Process and validate fields_config
      if permitted[:fields_config].present?
        permitted[:fields_config] = parse_fields_config(permitted[:fields_config])
      else
        permitted[:fields_config] = []
      end
      
      permitted
    end

    def update_params
      create_params
    end

    def parse_fields_config(fields_hash)
      return [] if fields_hash.blank?

      fields_array = []
      # Convert ActionController::Parameters to hash if needed
      fields_hash = fields_hash.to_unsafe_h if fields_hash.is_a?(ActionController::Parameters)
      
      # Handle hash with numeric keys like {"0" => {...}, "1" => {...}}
      sorted_fields = fields_hash.to_a.sort_by { |k, _v| k.to_i }
      
      sorted_fields.each do |_key, field_params|
        # Convert nested ActionController::Parameters to hash
        field_params = field_params.to_unsafe_h if field_params.is_a?(ActionController::Parameters)
        field_params = field_params.with_indifferent_access if field_params.is_a?(Hash)
        
        next if field_params[:type].blank? && field_params["type"].blank?

        type = (field_params[:type] || field_params["type"]).to_s
        field = {
          "id" => (field_params[:id] || field_params["id"] || SecureRandom.uuid).to_s,
          "type" => type.to_s,
          "label" => (field_params[:label] || field_params["label"]).to_s,
          "instructions" => (field_params[:instructions] || field_params["instructions"]).to_s,
          "required" => field_params[:required] == "1" || field_params[:required] == true || field_params["required"] == "1" || field_params["required"] == true,
          "points" => (field_params[:points] || field_params["points"] || 0).to_i
        }

        case type
        when "text_input"
          field["correct_answer"] = (field_params[:correct_answer] || field_params["correct_answer"] || "").to_s
        when "single_choice"
          options = field_params[:options] || field_params["options"] || []
          options = options.values if options.is_a?(Hash)
          options = options.to_unsafe_h.to_a if options.is_a?(ActionController::Parameters)
          field["options"] = Array(options).reject(&:blank?).map(&:to_s)
          field["correct_answer"] = (field_params[:correct_answer] || field_params["correct_answer"] || "").to_s
        when "multiple_choice"
          options = field_params[:options] || field_params["options"] || []
          options = options.values if options.is_a?(Hash)
          options = options.to_unsafe_h.to_a if options.is_a?(ActionController::Parameters)
          field["options"] = Array(options).reject(&:blank?).map(&:to_s)
          correct_answers = field_params[:correct_answers] || field_params["correct_answers"] || []
          correct_answers = correct_answers.values if correct_answers.is_a?(Hash)
          correct_answers = correct_answers.to_unsafe_h.to_a if correct_answers.is_a?(ActionController::Parameters)
          field["correct_answers"] = Array(correct_answers).reject(&:blank?).map(&:to_s)
        when "hidden_letter"
          field["image_url"] = (field_params[:image_url] || field_params["image_url"] || "").to_s
          field["display_text"] = (field_params[:display_text] || field_params["display_text"] || "").to_s
          field["number_of_blanks"] = (field_params[:number_of_blanks] || field_params["number_of_blanks"] || 1).to_i
          field["case_sensitive"] = field_params[:case_sensitive] == "1" || field_params[:case_sensitive] == true || field_params[:case_sensitive] == 1 || field_params["case_sensitive"] == "1" || field_params["case_sensitive"] == true || field_params["case_sensitive"] == 1
          field["correct_answer"] = (field_params[:correct_answer] || field_params["correct_answer"] || "").to_s
          field["hint"] = (field_params[:hint] || field_params["hint"] || "").to_s
        when "photo_upload"
          field["max_photos"] = (field_params[:max_photos] || field_params["max_photos"] || 1).to_i
          field["require_caption"] = field_params[:require_caption] == "1" || field_params[:require_caption] == true || field_params[:require_caption] == 1 || field_params["require_caption"] == "1" || field_params["require_caption"] == true || field_params["require_caption"] == 1
        end

        fields_array << field
      end
      fields_array
    end

    def search_form_params
      params.fetch(:admin_challenges_search_form, {}).permit(:title, :is_active)
    end
  end
end


