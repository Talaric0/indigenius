class ItemsController < ApplicationController
  before_action :set_item, only: %i[show edit update destroy]

  # GET /items
  # GET /items.json

  def index
    if params[:format].nil?
      @items = Item.all
       @markers = @items.geocoded.map do |item|
      {
        lat: item.latitude,
        lng: item.longitude
      }
    end
    else
      if params[:query].present?
        # if we do have a query, make the search 
        @items = Item.search_by_name_category_and_description(params[:query])
        # instance variable tracking where or not this is a workshop
        @item_type = params[:format]
      else 
        # otherwise, show all the items (workshops or products)
        @items = Item.where(workshop: params[:format])
        # instance variable tracking where or not this is a workshop
        @item_type = params[:format]
      end 
    end
  end

  #test comment pls delete


  # GET /items/1
  # GET /items/1.json
  def show
    @order_item = OrderItem.new
    @reviews = Review.where(item_id: @item.id)
  end

  def listings
    @items = Item.where('user_id = ?', current_user.id)
    @workshops = @items.where(workshop: true)
    @products = @items.where(workshop: false)
  end

  # GET /items/new
  def new
    @item = Item.new(workshop: params[:format])
    # @workshop_date = WorkshopDate.new(item_id: @item.id)
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items
  # POST /items.json
  def create
    @item = Item.new(item_params)
    @item.user = current_user
    # @item.save!
    # redirect_to listings_path, notice: 'Item was successfully created.'
    respond_to do |format|
      if @item.save!

        # if the item.workshop is true then redirect to the workshop date otherwise redirect to the workshop_date
        if @item.workshop
          format.html { redirect_to new_item_workshop_date_path(@item), notice: 'Item was successfully created.' }
          format.json { render :show, status: :created, location: @item }
        else 
          format.html { redirect_to listings_path, notice: 'Item was successfully created.' }
        end
      else
        format.html { render :new }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /items/1
  # PATCH/PUT /items/1.json
  def update
    respond_to do |format|
      if @item.update(item_params)

        # if the item.workshop is true then redirect to the workshop date otherwise redirect to the workshop_date
        if @item.workshop
          format.html { redirect_to new_item_workshop_date_path(@item), notice: 'Item was successfully updated.' }
          format.json { render :show, status: :created, location: @item }
        else 
          format.html { redirect_to listings_path, notice: 'Item was successfully updated.' }
        end
      else
        format.html { render :edit }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item.destroy
    respond_to do |format|
      format.html { redirect_to listings_url, notice: 'Item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_item
    @item = Item.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def item_params
    params.require(:item).permit(:name, :description, :user_id, :price, :category,
                                 :capacity, :quantity, :workshop, images: [])
  end
end
