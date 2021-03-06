# frozen_string_literal: true

class CoronavirusForm::OfferCareQualificationsController < ApplicationController
  before_action :check_first_question_answered, only: :show

  TEXT_FIELDS = %w(offer_care_qualifications_type).freeze

  def show
    session[:offer_care_qualifications] ||= []
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    offer_care_qualifications = Array(params[:offer_care_qualifications]).map { |item| sanitize(item).presence }.compact
    offer_care_qualifications_type = sanitize(params[:offer_care_qualifications_type]).presence

    session[:offer_care_qualifications] = offer_care_qualifications
    session[:offer_care_qualifications_type] = offer_care_qualifications_type

    invalid_fields = validate_field_response_length(PAGE, TEXT_FIELDS) +
      validate_checkbox_field(
        PAGE,
        values: offer_care_qualifications,
        allowed_values: I18n.t("coronavirus_form.questions.#{PAGE}.options").map { |_, item| item.dig(:label) },
        other: offer_care_qualifications_type,
        other_field: "nursing_or_healthcare_qualification",
      )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "coronavirus_form/#{PAGE}"
    elsif session["check_answers_seen"]
      redirect_to controller: "coronavirus_form/check_answers", action: "show"
    else
      redirect_to controller: "coronavirus_form/#{NEXT_PAGE}", action: "show"
    end
  end

private

  PAGE = "offer_care_qualifications"
  NEXT_PAGE = "offer_other_support"

  def previous_path
    offer_care_path
  end
end
