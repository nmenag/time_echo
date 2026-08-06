module Letters
  class UpdatePredictionsService
    def self.call(letter_id_or_signed_id, params, current_user_email)
      new(letter_id_or_signed_id, params, current_user_email).call
    end

    def initialize(letter_id_or_signed_id, params, current_user_email)
      @letter_id_or_signed_id = letter_id_or_signed_id
      @params = params
      @current_user_email = current_user_email
    end

    def call
      letter, accessed_via_signed_id = find_letter

      if letter.nil? || letter.pending?
        return Result.new(success: false, error: :not_found)
      end

      policy = LetterPolicy.new(@current_user_email, letter)
      unless accessed_via_signed_id || policy.show?
        return Result.new(success: false, error: :unauthorized)
      end

      Letter.transaction do
        letter.update!(
          reveal_happiness: @params[:reveal_happiness],
          reveal_anxiety: @params[:reveal_anxiety],
          reveal_motivation: @params[:reveal_motivation]
        )

        if @params[:predictions].present?
          @params[:predictions].each do |pred_id, pred_params|
            prediction = letter.predictions.find_by(id: pred_id)
            if prediction
              prediction.update!(
                reality: pred_params[:reality],
                matched: ActiveModel::Type::Boolean.new.cast(pred_params[:matched])
              )
            end
          end
        end

        Analytics::TrackEventService.call("prediction_completion", { letter_id: letter.id, email: letter.email })
        Analytics::TrackEventService.call("emotional_snapshot_completion", { letter_id: letter.id, email: letter.email })
      end

      Result.new(success: true, letter: letter)
    rescue ActiveRecord::RecordInvalid => e
      Result.new(success: false, error: :invalid, message: e.message)
    end

    private

def find_letter
  letter = Letter.find_signed(@letter_id_or_signed_id.to_s)
  return [ letter, true ] if letter

  if @current_user_email.present?
    letter = Letter.find_by(id: @letter_id_or_signed_id, email: @current_user_email)
    return [ letter, false ] if letter

    letter = Letter.find_by(id: @letter_id_or_signed_id)
    return [ letter, false ] if letter
  end

  [ nil, false ]
end

    class Result
      attr_reader :letter, :error, :message
      def initialize(success:, letter: nil, error: nil, message: nil)
        @success = success
        @letter = letter
        @error = error
        @message = message
      end

      def success?
        @success
      end
    end
  end
end
