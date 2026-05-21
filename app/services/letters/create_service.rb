module Letters
  class CreateService
    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @params = params
    end

    def call
      form = LetterForm.new(@params)
      if form.save
        Result.new(success: true, letter: form.letter)
      else
        Result.new(success: false, errors: form.errors)
      end
    end

    class Result
      attr_reader :letter, :errors
      def initialize(success:, letter: nil, errors: nil)
        @success = success
        @letter = letter
        @errors = errors
      end

      def success?
        @success
      end
    end
  end
end
