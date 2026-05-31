class PublicLettersController < ApplicationController
  def index
    @letters = PublicLettersQuery.call
  end
end
