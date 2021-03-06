# Count Quarks as being clicked
class QuarksController < ApplicationController
  before_action :require_login, only: [:create]

  def index
  end

  def create
    @quark = Quark.new(quark_params)
    @quark.user = current_user

    if @quark.save
      update_count_cache(@quark.count)
    else
      @quark.errors.full_messages.each do |message|
        flash[:error] = message
      end
    end

    redirect_to root_url
  end

  private

  def require_login
    return if current_user

    flash[:errors] = 'You must be signed in to count'
    redirect_to root_url
  end

  def quark_params
    params.require(:quark).permit(:count)
  end

  # Update the Quark count for faster retrevial by other clients
  def update_count_cache(count)
    current_count = Rails.cache.fetch(:quark_count) { Quark.sum(:count) }
    Rails.cache.write(:quark_count, current_count + count)
  end
end
