class BusinessCategoriesController < ApplicationController
  before_action :set_business_category, only: [:show, :edit, :update, :destroy]


  def index
    @business_categories = BusinessCategory.all
  end


  def show
  end


  def new
    @business_category = BusinessCategory.new
  end


  def edit
  end


  def create
    @business_category = BusinessCategory.new(business_category_params)

    if @business_category.save
      format.html { redirect_to @business_category, notice: 'Business category was successfully created.' }
    else
      format.html { render :new }
    end
  end


  def update
    if @business_category.update(business_category_params)
      format.html { redirect_to @business_category, notice: 'Business category was successfully updated.' }
    else
      format.html { render :edit }
    end

  end


  def destroy
    @business_category.destroy

    format.html { redirect_to business_categories_url, notice: 'Business category was successfully destroyed.' }

  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_business_category
    @business_category = BusinessCategory.find(params[:id])
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def business_category_params
    params.require(:business_category).permit(:name, :description)
  end
end
