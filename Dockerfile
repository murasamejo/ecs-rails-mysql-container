FROM ruby:3.0

# TODO: Node.js はバージョンが指定できるように、公式から引っ張ってくるようにする
RUN apt update -qq && apt install -y nodejs

WORKDIR /myapp

# 基本的に全部コピーの設定にして .dockerignore で除外するものを制御する
COPY . /myapp
# COPY Gemfile /myapp/Gemfile
# COPY Gemfile.lock /myapp/Gemfile.lock

RUN bundle install

# コンテナが開始されるたびに実行される内容
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]
