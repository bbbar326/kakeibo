class RootController < ApplicationController
  def index
    # 先々月の合計値
    @last_last_month_summary = Receipt.joins(:receipt_details).where(date: Time.current.last_month.last_month.all_month).sum(:price)
    # 先月の合計値
    @last_month_summary = Receipt.joins(:receipt_details).where(date: Time.current.last_month.all_month).sum(:price)
    # 今月の合計値
    @this_month_summary = Receipt.joins(:receipt_details).where(date: Time.current.all_month).sum(:price)
  end
end
