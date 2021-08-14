# qiita-ruby3.0-docker

docker-compose を使って Ruby 3.0 を構築する.

導入したいパッケージがあれば、PV/rb/app/Gemfile に記しておくと、
bundler によってインストールされる.

```
docker-compose build --no-cache
docker-compose up -d
```
