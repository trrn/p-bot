# vim:ts=2 sw=2 ts=2 et:
kuromoji = require 'kuromoji'

BEGIN_DELIM = '__BEGIN__'
END_DELIM = '__END__'

class Parser
  @parse: (str, callback) ->
    kuromoji.builder(dicPath:'node_modules/kuromoji/dist/dict/')
      .build((err, tokenizer) ->
        if err
          callback(err, null)
          return

        tokens_list = []
        for line in str.split(/\n/)
          line = line.trim()
          continue unless line        # empty
          continue if /^#/.test line  # comment
          tokens = tokenizer.tokenize(line)
          tokens = (token.surface_form for token in tokens)
          tokens.unshift BEGIN_DELIM
          tokens.push END_DELIM
          tokens_list.push(tokens)

        callback(null, tokens_list)
      )

module.exports = Parser
