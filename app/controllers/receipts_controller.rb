require 'rexml/document'

class ReceiptsController < ApplicationController
  before_action :set_receipt, only: [:show, :edit, :update, :destroy]

  # GET /receipts
  # GET /receipts.json
  def index
    @receipts = Receipt.preload(:store, :receipt_details).all
  end

  # GET /xml_upload
  def xml_upload
    msg = ""
    saved_record_num = 0

    doc = REXML::Document.new(open(File.join(Rails.root,"tmp","receipt_date_test.xml")))
    doc.elements.each('receipt_data/receipt_list/receipt') do |receipt|

      next unless receipt

      store_name = receipt.elements['store']&.text
      store_tel = receipt.elements['tel']&.text
      date = receipt.elements['date']&.text

      date = nil unless date_valid?(date)

      # --------------------------------------------------------------------------------
      # 電文解析
      # --------------------------------------------------------------------------------

      # 店舗
      # nameとtelで検索してすでに存在していればその値を取得
      store = Store.find_or_initialize_by(name: store_name, tel: store_tel)

      # 明細
      receipt_detail_list = []

      receipt.elements.each('item_list/item') do |receipt_detail|
        receipt_detail_price = receipt_detail.elements['price']&.text&.to_i
        receipt_detail_name = receipt_detail.elements['name']&.text
        receipt_detail_list << {price: receipt_detail_price, name: receipt_detail_name}
      end
      
      # --------------------------------------------------------------------------------
      # バリデーション
      # ・日付、店舗の電話番号、合計金額が一致してるレコードを取得。
      # ・一致してたレコードのうち、明細も全て同じの場合は登録済みとしてスキップ。
      # ・[TODO]明細が違う場合は、登録は実行しておいて警告を出す。
      # --------------------------------------------------------------------------------

      hits = Receipt.joins(:store, :receipt_details).where(date: date, stores: {tel: store_tel, name: store_name})

      if hits.present?
        # 日付、店舗の電話番号が一致しているレコードある場合

        isExistReceipt = false
        total = receipt_detail_list.sum { |hash| hash[:price]}

        hits.each do |hit|
          isMatchPrice = false
          isMatchDetail = false
          # 金額を確認
          if hit.receipt_details.sum(:price) == total
            isMatchPrice = true
          end

          # 金額が合致している場合は明細を確認
          if isMatchPrice
            isMatchDetail = true
            hit.receipt_details.each_with_index do |hit_receipt_detail, i|
              if receipt_detail_list[i][:name] != hit_receipt_detail.name
                isMatchDetail = false
                break
              end
            end
          end

          # 金額と明細が一致したレコードは無視する
          if isMatchPrice && isMatchDetail
            isExistReceipt = true
            break
          end
        end

        next if isExistReceipt

      end

      
      # 登録
      new_receipt = Receipt.create(date: date, store: store)
      new_receipt.receipt_details.create(receipt_detail_list)
      saved_record_num += 1
      
    end
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

    @receipt = Receipt.new(date: date, store_id: receipt_params[:store_id])
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
      @receipt = Receipt.preload(:store, :receipt_details).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def receipt_params
      params.require(:receipt).permit(:date, :store_id, receipt_details_attributes: [:id, :name, :price])
    end

    def date_valid?(str)
      !! Date.parse(str) rescue false
    end
end
