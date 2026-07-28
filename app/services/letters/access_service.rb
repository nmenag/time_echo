module Letters
  class AccessService
    def self.call(id_or_signed_id, current_user_email)
      new(id_or_signed_id, current_user_email).call
    end

    def initialize(id_or_signed_id, current_user_email)
      @id_or_signed_id = id_or_signed_id
      @current_user_email = current_user_email
    end

    def call
      letter, accessed_via_signed_id = find_letter

      if letter.nil?
        return Result.new(success: false, error: :not_found)
      end

      policy = LetterPolicy.new(@current_user_email, letter)
      unless accessed_via_signed_id || policy.show?
        return Result.new(success: false, error: :unauthorized)
      end

      countdown = letter.pending?

      unless countdown
        if letter.opened_at.nil?
          letter.update!(opened_at: Time.current)
          Analytics::TrackEventService.call("letter_opened", { letter_id: letter.id, email: letter.email })
        end
        letter.increment!(:open_count)
      end

      Result.new(success: true, letter: letter, countdown: countdown)
    end

    private

    def find_letter
      # 1. Look up by signed ID
      letter = Letter.find_signed(@id_or_signed_id.to_s)
      return [ letter, true ] if letter

      # 2. If user is signed in, look up letters owned by that user
      if @current_user_email.present?
        letter = Letter.find_by(id: @id_or_signed_id, email: @current_user_email)
        return [ letter, false ] if letter
      end

      [ nil, false ]
    end

    class Result
      attr_reader :letter, :error, :countdown
      def initialize(success:, letter: nil, error: nil, countdown: false)
        @success = success
        @letter = letter
        @error = error
        @countdown = countdown
      end

      def success?
        @success
      end

      def countdown?
        @countdown
      end
    end
  end
end
