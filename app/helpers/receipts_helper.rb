module ReceiptsHelper

  #
  # ストア名, ストアID の一覧を取得します
  #
  def store_list
    Store.all.order(:id).pluck(:name, :id)
  end
end
