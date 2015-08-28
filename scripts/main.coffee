# vim:ts=2 sw=2 ts=2 et:
# Description
#   哲学発言的bot
#   ある文章の塊を形態素解析し、
#   ランダムな文章をマルコフ連鎖で作成
#
# Dependencies:
#   "kuromoji": "0.0.2"
#
# Commands:
#   hubot .*
#
# Notes:
#   textbook.txt - 1文ごとに改行された文章の塊(必須)
#   parsed.json  - textbook.txtを形態素解析したもの(herokuへデプロイする際には必須)
#
# Author:
#   trrn
#
fs = require 'fs'
Markov = require './markov'
Parser = require './parser'

PATH_FOR_PARSE = 'textbook.txt'
PARSED_JSON_PATH = 'parsed.json'  # as cache
PHILOSOPHICAL_WORDS = '誠実|品質|思いやり|効率|フィロソフィー|philosophy|joymap'
CLEAR_CACHE_WORDS = 'clear cache'
HELP_WORDS = 'help|usage|info|man|manual|doc|desc|ヘルプ|へるぷ|使い方|使いかた|説明'
GREETING_WORDS = 'あいさつ|挨拶|こんにち|hello|hi'
REPO_URL = 'https://github.com/trrn/p-bot'

do_not_search = false

module.exports = (robot) ->
  robot.hear ///#{PHILOSOPHICAL_WORDS}///i, (res) ->
    do_not_search = true
    respond_philosophy(res)

  robot.respond /(.*)/, (res) ->
    if ///#{GREETING_WORDS}///i.test res.match[1]
      res.send "こんにちは。\n"
      usage res

    else if ///^\s*#{CLEAR_CACHE_WORDS}\s*$///i.test res.match[1]
      fs.unlink(PARSED_JSON_PATH, (err) ->
        if err
          robot.logger.error err
          res.send err
        else
          res.send "#{CLEAR_CACHE_WORDS} done."
      )

    else if ///^\s*#{HELP_WORDS}\s*$///i.test res.match[1]
      usage res

    else
      unless do_not_search
        respond_philosophy res  # search
      do_not_search = false

  respond_philosophy = (res) ->
    if fs.existsSync(PARSED_JSON_PATH) # if cache exists
      # read parsed cache
      tokens_list = JSON.parse(fs.readFileSync(PARSED_JSON_PATH,'utf8'))
      run_markov(res, tokens_list)
    else
      Parser.parse(fs.readFileSync(PATH_FOR_PARSE,'utf8'), (err, tokens_list) ->
        if err
          robot.logger.error err
          res.send err
          return

        # save parsed cache
        fs.writeFile('parsed.json', JSON.stringify(tokens_list), (err) ->
          if err
            robot.logger.error err
            res.send err
        )

        run_markov(res, tokens_list)
      )

  run_markov = (res, tokens_list) ->
    markov = new Markov()
    markov.study(tokens) for tokens in tokens_list
    if res.match[1]
      keyword = res.match[1].trim()
      keyword = keyword.replace(///^@#{robot.name}:?///, '').trim()
      res.send "_" + markov.search(keyword).join('') + "_"
    else
      res.send "_" + markov.compose().join('') + "_"

  usage = (res) ->
    res.send "次の言葉に勝手に反応します\n`" + PHILOSOPHICAL_WORDS + "`\n\n" + \
             "メンションを送ると検索？します\n`\@#{robot.name} 土俵`\n\n" + \
             "ボットを追い出す\n`/kick @#{robot.name}`\n\n" + \
             "ボットを招待する\n`/invite @#{robot.name}`"

