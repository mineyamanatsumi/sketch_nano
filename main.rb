require 'sinatra'
require 'sqlite3'
require 'sinatra/json'
require 'data_uri'
require 'securerandom'
require 'logger'

logger = Logger.new(STDOUT)

# DBの生成
db = SQLite3::Database.new 'db/post.db'
db.results_as_hash = true

get '/' do
  erb :index
end

get '/dashboard' do
  if params[:r18] == "true"
    posts = db.execute("SELECT * FROM pictures WHERE adult = 1 ORDER BY id DESC")
  else
    posts = db.execute("SELECT * FROM pictures ORDER BY id DESC")
  end
  erb :dashboard, {:locals => {:posts => posts}}
end

get '/draw' do
  erb :draw
end

post '/draw' do
  datauri = params['src']
  r18bunrui= "#{params['r18']}"
  img = URI::Data.new(datauri).data

  # ファイル名をつける
  name = SecureRandom.hex + '.png'

  # 画像を保存
  File.open("./public/uploads/" + name, "wb") do |file|
    file.write img
  end

  #DBに登録する
  time = Time.now.strftime('%Y-%m-%d %H:%M:%S')
#  sql = "INSERT INTO pictures (title, src, posted_at, adult) VALUES ('#{params['title']}', '#{name}', '#{time}', '#{r18bunrui}')"
  sql = "INSERT INTO pictures (title, src, posted_at, adult) VALUES (?, ?, ?, ?')"
 db.execute_batch(sql,[params['title'], name, time, params['r18bunrui']])

  db.execute_batch(sql)

  # 終わったらダッシュボードに戻る
  redirect '/dashboard'
end

post '/api/like' do
  # javascriptから送られてきた値を受け取る
  dataid = params['dataid']

  # 1を足した結果を、データベースのそのIDのところに保存する
  db.execute_batch("UPDATE pictures SET likes = likes+1 WHERE id = #{dataid}")

  # resultをjsonで渡す
  posts = db.execute("SELECT * FROM pictures where id = ?")
  db.execute_batch(sql,[dataid])

  p posts
  result = { like: posts[0]['likes'] }

  json result
end
