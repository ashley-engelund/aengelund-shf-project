class AdminOnly::MasterChecklistTypesController < ApplicationController
  before_action :set_admin_only_master_checklist_type, only: [:show, :edit, :update, :destroy]

  # GET /admin_only/master_checklist_types
  # GET /admin_only/master_checklist_types.json
  def index
    @admin_only_master_checklist_types = AdminOnly::MasterChecklistType.all
  end

  # GET /admin_only/master_checklist_types/1
  # GET /admin_only/master_checklist_types/1.json
  def show
  end

  # GET /admin_only/master_checklist_types/new
  def new
    @admin_only_master_checklist_type = AdminOnly::MasterChecklistType.new
  end

  # GET /admin_only/master_checklist_types/1/edit
  def edit
  end

  # POST /admin_only/master_checklist_types
  # POST /admin_only/master_checklist_types.json
  def create
    @admin_only_master_checklist_type = AdminOnly::MasterChecklistType.new(admin_only_master_checklist_type_params)

    respond_to do |format|
      if @admin_only_master_checklist_type.save
        format.html { redirect_to @admin_only_master_checklist_type, notice: 'Master checklist type was successfully created.' }
        format.json { render :show, status: :created, location: @admin_only_master_checklist_type }
      else
        format.html { render :new }
        format.json { render json: @admin_only_master_checklist_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin_only/master_checklist_types/1
  # PATCH/PUT /admin_only/master_checklist_types/1.json
  def update
    respond_to do |format|
      if @admin_only_master_checklist_type.update(admin_only_master_checklist_type_params)
        format.html { redirect_to @admin_only_master_checklist_type, notice: 'Master checklist type was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_only_master_checklist_type }
      else
        format.html { render :edit }
        format.json { render json: @admin_only_master_checklist_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin_only/master_checklist_types/1
  # DELETE /admin_only/master_checklist_types/1.json
  def destroy
    @admin_only_master_checklist_type.destroy
    respond_to do |format|
      format.html { redirect_to admin_only_master_checklist_types_url, notice: 'Master checklist type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_only_master_checklist_type
      @admin_only_master_checklist_type = AdminOnly::MasterChecklistType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_only_master_checklist_type_params
      params.require(:admin_only_master_checklist_type).permit(:name, :description)
    end
end
