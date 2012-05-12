class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!
  protect_from_forgery :except => :create

  def index
    account = Recurly::Account.find(current_user.recurly_account_code)
    logger.info account

    @subscriptions = account.subscriptions
  end

  def new
    @plan_code = 'annual'
    @signature = Recurly.js.sign :subscription => { :plan_code => @plan_code }
  end

  def create
    result = Recurly.js.fetch(params[:recurly_token])
    logger.info result

    subscription = Subscription.new do |s|
      s.user = current_user
      s.recurly_uuid = result.uuid
    end

    subscription.save!
    flash[:success] = 'Subscription was successfully created!'

    redirect_to subscriptions_path
  end
end