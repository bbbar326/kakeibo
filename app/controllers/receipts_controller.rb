require 'rexml/document'

class ReceiptsController < ApplicationController
  before_action :set_receipt, only: [:show, :edit, :update, :destroy]

  # GET /receipts
  # GET /receipts.json
  def index
     if search_params[:search]
       @receipts = Receipt.search(search_params[:search]).preload(:store, :receipt_details, :pay_account, receipt_details: :expense).order(date: "DESC")
     else
       @receipts = Receipt.preload(:store, :receipt_details, :pay_account, receipt_details: :expense).order(date: "DESC").all  
     end

     respond_to do |format|
       format.html
       format.json
       format.csv { send_data @receipts.to_csv }
     end
  end

  # POST /csv_upload
  def csv_upload
    msg = ""
    saved_record_num = 0

    file = csv_params[:csv_upload]

    saved_record_num = Receipt.from_csv(file)

    msg += "CSV import succeed!#{saved_record_num}件登録しました。"
    flash[:notice] = msg
    redirect_to action: "index"
  end

  # POST /xml_upload
  def xml_upload
    msg = ""
    file = xml_params[:xml_upload]

    saved_record_num = Receipt.from_xml(file)

    msg += "XML import succeed!#{saved_record_num}件登録しました。"

    flash[:notice] = msg
    redirect_to action: "index"
  end

  # GET /receipts/1
  # GET /receipts/1.json
  def show
  end

  # GET /receipts/new
  def new
    @receipt = Receipt.new
    2.times { @receipt.receipt_details.build }
  end

  # GET /receipts/1/edit
  def edit
  end

  # POST /receipts
  # POST /receipts.json
  def create
    date = Date.new(receipt_params["date(1i)"].to_i, receipt_params["date(2i)"].to_i, receipt_params["date(3i)"].to_i)

    @receipt = Receipt.new(date: date, store_id: receipt_params[:store_id], pay_account_id: receipt_params[:pay_account_id])
    receipt_params[:receipt_details_attributes].to_h.values.each do |receipt_detail|
      # id, store_id, priceいずれも入力値が空の場合は除外
      next if receipt_detail.values.all?{|e| e.blank?}

      @receipt.receipt_details.build(receipt_detail)
    end

    respond_to do |format|
      if @receipt.save
        format.html { redirect_to @receipt, notice: 'Receipt was successfully created.' }
        format.json { render :show, status: :created, location: @receipt }
      else
        format.html { render :new }
        format.json { render json: @receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /receipts/1
  # PATCH/PUT /receipts/1.json
  def update
    respond_to do |format|
      if @receipt.update(receipt_params)
        format.html { redirect_to @receipt, notice: 'Receipt was successfully updated.' }
        format.json { render :show, status: :ok, location: @receipt }
      else
        format.html { render :edit }
        format.json { render json: @receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /receipts/1
  # DELETE /receipts/1.json
  def destroy
    @receipt.destroy
    respond_to do |format|
      format.html { redirect_to receipts_url, notice: 'Receipt was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_receipt
      @receipt = Receipt.preload(:store, :pay_account, :receipt_details).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def receipt_params
      params.require(:receipt).permit(
        :date, 
        :store_id, 
        :pay_account_id, 
        receipt_details_attributes: [:id, :name, :price, :expense_id])
    end

    def search_params
      params.permit(:search)
    end

    def xml_params
      params.permit(:xml_upload)
    end

    def csv_params
      params.permit(:csv_upload)
    end
end
