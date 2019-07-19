FROM nginx

# インクルード用のディレクトリ内を削除
RUN rm -f /etc/nginx/conf.d/*

# Nginxの設定ファイルをコンテナにコピー
ADD webapp.conf /etc/nginx/conf.d/webapp.conf

# ビルド完了後にNginxを起動
#CMD /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf

