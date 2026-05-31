module Settings
  class DestroyAccountService
    def self.call(email, user_preference)
      new(email, user_preference).call
    end

    def initialize(email, user_preference)
      @email = email
      @user_preference = user_preference
    end

    def call
      ActiveRecord::Base.transaction do
        letters = Letter.where(email: @email)
        letter_ids = letters.pluck(:id)

        if letter_ids.any?
          conn = ActiveRecord::Base.connection
          %w[reactions comments goals predictions emotional_snapshots].each do |table|
            conn.execute(conn.sanitize_sql_array([ "DELETE FROM #{table} WHERE letter_id IN (?)", letter_ids ])) rescue nil
          end
        end

        letters.destroy_all
        @user_preference.destroy!
        AnalyticsEvent.where("metadata ->> 'email' = ?", @email).delete_all rescue nil
      end
      true
    end
  end
end
