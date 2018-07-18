class ReceiptDetailsController < ApplicationController
  before_action :set_receipt_detail, only: [:show, :edit, :update, :destroy]

  # GET /receipt_details
  # GET /receipt_details.json
  def index
    @receipt_details = ReceiptDetail.all
  end

  # GET /receipt_details/1
  # GET /receipt_details/1.json
  def show
  end

  # GET /receipt_details/new
  def new
    @receipt_detail = ReceiptDetail.new
  end

  # GET /receipt_details/1/edit
  def edit
  end

  # POST /receipt_details
  # POST /receipt_details.json
  def create
    @receipt_detail = ReceiptDetail.new(receipt_detail_params)

    respond_to do |format|
      if @receipt_detail.save
        format.html { redirect_to @receipt_detail, notice: 'Receipt detail was successfully created.' }
        format.json { render :show, status: :created, location: @receipt_detail }
      else
        format.html { render :new }
        format.json { render json: @receipt_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /receipt_details/1
  # PATCH/PUT /receipt_details/1.json
  def update
    respond_to do |format|
      if @receipt_detail.update(receipt_detail_params)
        format.html { redirect_to @receipt_detail, notice: 'Receipt detail was successfully updated.' }
        format.json { render :show, status: :ok, location: @receipt_detail }
      else
        format.html { render :edit }
        format.json { render json: @receipt_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /receipt_details/1
  # DELETE /receipt_details/1.json
  def destroy
    @receipt_detail.destroy
    respond_to do |format|
      format.html { redirect_to receipt_details_url, notice: 'Receipt detail was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_receipt_detail
      @receipt_detail = ReceiptDetail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def receipt_detail_params
      params.require(:receipt_detail).permit(:expense_id, :price, :name, :receipt_id)
    end
end
