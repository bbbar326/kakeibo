class RootController < ApplicationController
  def index
    # ---------------------------------------------------------
    # 経費種別合計値
    # ---------------------------------------------------------
    # 先々月の経費別合計値
    @last_last_month_expenses_sum = Receipt.joins(:receipt_details).where(date: Time.current.last_month.last_month.all_month).group(:expense_id).sum(:price)
    # 先月の経費別合計値
    @last_month_expenses_sum = Receipt.joins(:receipt_details).where(date: Time.current.last_month.all_month).group(:expense_id).sum(:price)
    # 今月の経費別合計値
    @this_month_expenses_sum = Receipt.joins(:receipt_details).where(date: Time.current.all_month).group(:expense_id).sum(:price)

    # ---------------------------------------------------------
    # 合計
    # ---------------------------------------------------------
    # 先々月の合計値
    @last_last_month_sum = @last_last_month_expenses_sum.values.sum
    # 先月の合計値
    @last_month_sum = @last_month_expenses_sum.values.sum
    # 今月の合計値
    @this_month_sum = @this_month_expenses_sum.values.sum

  end
end
