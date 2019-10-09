class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  #TODO 仕様が固まるまで、簡単にサインアップできないようにする
  #  devise :database_authenticatable, :registerable,
  devise :database_authenticatable,
:recoverable, :rememberable, :validatable
end
