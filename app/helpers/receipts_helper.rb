module ReceiptsHelper

  #
  # ストア名, ストアID の一覧を取得します
  #
  def store_list
    @store_list ||= Store.all.order(:id).pluck(:name, :id)
  end

  #
  # 経費種別名, 経費種別ID の一覧を取得します
  #
  def expense_list
    @expense_list ||= Expense.all.order(:id).pluck(:name, :id)
  end
end
