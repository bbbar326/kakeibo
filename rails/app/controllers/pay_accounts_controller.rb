class PayAccountsController < ApplicationController
  before_action :set_pay_account, only: [:show, :edit, :update, :destroy]

  # GET /pay_accounts
  # GET /pay_accounts.json
  def index
    @pay_accounts = PayAccount.all
  end

  # GET /pay_accounts/1
  # GET /pay_accounts/1.json
  def show
  end

  # GET /pay_accounts/new
  def new
    @pay_account = PayAccount.new
  end

  # GET /pay_accounts/1/edit
  def edit
  end

  # POST /pay_accounts
  # POST /pay_accounts.json
  def create
    @pay_account = PayAccount.new(pay_account_params)

    respond_to do |format|
      if @pay_account.save
        format.html { redirect_to @pay_account, notice: 'Pay account was successfully created.' }
        format.json { render :show, status: :created, location: @pay_account }
      else
        format.html { render :new }
        format.json { render json: @pay_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pay_accounts/1
  # PATCH/PUT /pay_accounts/1.json
  def update
    respond_to do |format|
      if @pay_account.update(pay_account_params)
        format.html { redirect_to @pay_account, notice: 'Pay account was successfully updated.' }
        format.json { render :show, status: :ok, location: @pay_account }
      else
        format.html { render :edit }
        format.json { render json: @pay_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pay_accounts/1
  # DELETE /pay_accounts/1.json
  def destroy
    @pay_account.destroy
    respond_to do |format|
      format.html { redirect_to pay_accounts_url, notice: 'Pay account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pay_account
      @pay_account = PayAccount.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pay_account_params
      params.require(:pay_account).permit(:name)
    end
end
