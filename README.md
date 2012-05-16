miteru.cnosuke.com
==================

# これは何
今みているWEBサイトをすぐにTweetするためのwebあぷり。
Tweet URL which you are watching just in time.

# 動いている例がみたい
http://miteru.cnosuke.com/
ここで動いてます

# 注意
このwebアプリを動かすには
config/environment.rb
にdev.twitter.comで取得したOAuthの鍵を書く必要がありますよ。

あと、デフォルトはux.nuでURLは短縮しますが、もしgoo.glで短縮したいなら
app/controllers/users_controller.rb
のgoo_glメソッド内にgoo.glのAPIのURLを入力する必要がありますよ。

