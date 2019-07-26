module ApplicationHelper
  #
  # ストア名, ストアID の一覧を取得します
  #
  def store_list
    @store_list ||= Store.all.order(:id).pluck(:name, :id)
  end

  #
  # 支払い口座名, 支払い口座ID の一覧を取得します
  #
  def pay_account_list
    @pay_account_list ||= PayAccount.all.order(:id).pluck(:name, :id)
  end

  #
  # 経費種別名, 経費種別ID の一覧を取得します
  #
  def expense_list(*id_or_names)
    @expense_list ||= Expense.all.order(:id).pluck(:name, :id)

    return @expense_list if id_or_names.blank?

    result = []
    @expense_list.each {|data|
      # ----------------------------------------------
      # 引数で指定した値が存在する配列のみ返却
      # ----------------------------------------------
      # example：
      # @expense_list = [["食費(外食除く)", 1], ["日用品", 4], ["デート", 5]]
      # 
      # called:
      # expense_list(4) #=> [["日用品", 4]]
      # expense_list("日用品") #=> [["日用品", 4]]
      # expense_list(4, 5) #=> [["日用品", 4], ["デート", 5]]
      # expense_list(4, "デート") #=> [["日用品", 4], ["デート", 5]]
      # 
      result.push data if id_or_names.any? {|i| data.include?(i)}
    }
    result
  end
end
