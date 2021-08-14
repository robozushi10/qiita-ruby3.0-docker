FROM ruby:3.0-slim-buster

## プロキシサーバを使う場合
# ENV http_proxy="http://proxy.co.jp:8080"  
# ENV https_proxy="http://proxy.co.jp:8080"
  
# コンテナ内での作業場所を /usr/src/app とする
WORKDIR /usr/src/app
  
# Ruby に関する環境変数
  
# 日本環境に合わせる
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
ENV LANGUAGE ja_JP.UTF-8
ENV LANG ja_JP.UTF-8

