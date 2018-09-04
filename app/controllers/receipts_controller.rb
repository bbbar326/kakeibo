require 'rexml/document'

class ReceiptsController < ApplicationController
  before_action :set_receipt, only: [:show, :edit, :update, :destroy]

  # GET /receipts
  # GET /receipts.json
  def index
    @receipts = Receipt.all
  end

  # GET /xml_upload
  def xml_upload
    doc = REXML::Document.new(open(File.join(Rails.root,"tmp","receipt_date_test.xml")))
    doc.elements.each('receipt_data/receipt_list/receipt') do |receipt|
      store_name = receipt.elements['store'].text
      store_tel = receipt.elements['tel'].text
      date = receipt.elements['date'].text

      # nameとtelで検索してすでに存在していればその値を取得
      store = Store.find_or_initialize_by(name: store_name, tel: store_tel)

      new_receipt = Receipt.create(date: date, store: store)

      receipt.elements.each('item_list/item') do |receipt_detail|
        receipt_detail_price = receipt_detail.elements['price'].text
        receipt_detail_name = receipt_detail.elements['name'].text

        new_receipt.receipt_details.create(price: receipt_detail_price, name: receipt_detail_name)

      end
    end

    flash[:notice] = "XML import succeed!"
    redirect_to action: "index"
  end

  # GET /receipts/1
  # GET /receipts/1.json
  def show
  end

  # GET /receipts/new
  def new
    @receipt = Receipt.new
  end

  # GET /receipts/1/edit
  def edit
  end

  # POST /receipts
  # POST /receipts.json
  def create
    @receipt = Receipt.new(receipt_params)

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
      @receipt = Receipt.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def receipt_params
      params.require(:receipt).permit(:date, :store_id)
    end
end
