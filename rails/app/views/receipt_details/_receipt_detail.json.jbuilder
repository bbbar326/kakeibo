json.extract! receipt_detail, :id, :expense_id, :price, :name, :created_at, :updated_at
json.url receipt_detail_url(receipt_detail, format: :json)
