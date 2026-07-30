require "test_helper"

class Letters::UpdatePredictionsServiceTest < ActiveSupport::TestCase
  setup do
    @owner_email = "owner@example.com"
    @delivered_letter = Letter.new(
      title: "Delivered Letter",
      email: @owner_email,
      content: "Secret content.",
      deliver_at: 1.day.ago,
      delivered_at: 1.day.ago,
      status: "delivered"
    )
    @delivered_letter.save!(validate: false)
    @prediction = @delivered_letter.predictions.create!(category: "city", prediction: "Rome")

    @pending_letter = Letter.new(
      title: "Pending Letter",
      email: @owner_email,
      content: "Secret details.",
      deliver_at: 1.year.from_now,
      status: "pending"
    )
    @pending_letter.save!(validate: false)
  end

  test "updates predictions, reveal values and tracks analytics on success" do
    assert_difference -> { AnalyticsEvent.where(event_type: "prediction_completion").count } => 1 do
      result = Letters::UpdatePredictionsService.call(
        @delivered_letter.id,
        {
          reveal_happiness: 8,
          reveal_anxiety: 2,
          reveal_motivation: 9,
          predictions: {
            @prediction.id.to_s => { reality: "Milan", matched: "1" }
          }
        },
        @owner_email
      )

      assert result.success?
      @delivered_letter.reload
      assert_equal 8, @delivered_letter.reveal_happiness
      assert_equal 2, @delivered_letter.reveal_anxiety
      assert_equal 9, @delivered_letter.reveal_motivation

      @prediction.reload
      assert_equal "Milan", @prediction.reality
      assert @prediction.matched?
    end
  end

  test "returns not_found error for pending letters" do
    result = Letters::UpdatePredictionsService.call(
      @pending_letter.id,
      { reveal_happiness: 8 },
      @owner_email
    )

    assert_not result.success?
    assert_equal :not_found, result.error
  end

  test "returns not_found error for other users' private letters" do
    result = Letters::UpdatePredictionsService.call(
      @delivered_letter.id,
      { reveal_happiness: 8 },
      "unauthorized@example.com"
    )

    assert_not result.success?
    assert_equal :not_found, result.error
  end
end
