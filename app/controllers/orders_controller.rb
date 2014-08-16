class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing, only: [:new, :create]

  def purchases
    @orders = Order.purchases(current_user).includes(:seller).includes(:listing).recent
  end

  def sales
    @orders = Order.sales(current_user).includes(:buyer).includes(:listing).recent
  end

  def new
    @order = Order.new
  end

  def create
    success = true
    @order = Order.new(order_params)
    @order.buyer_id = current_user.id
    @order.seller_id = @listing.user.id
    @order.listing_id = @listing.id

    card_token = params[:cardToken]
    Stripe.api_key = ENV["STRIPE_API_KEY"]

    begin
    Stripe::Charge.create(
      :amount => (@listing.price*100).floor,
      :currency => "usd",
      :card => card_token,
      # obtained with Stripe.js
      :description => "Charge for #{@listing.name}"
    )
    flash[:notice] = "Thanks for ordering"
    rescue Stripe::CardError => e
      success = false
      flash[:alert] = e.message
    end

    respond_to do |format|
      if success && @order.save
        format.html { redirect_to root_path }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def order_params
    params.require(:order).permit(:address, :city, :state)
  end

  def set_listing
    begin
      @listing = Listing.find(params[:listing_id])
    rescue Exception => e
      redirect_to root_url, alert: e.message
    end
  end
end
