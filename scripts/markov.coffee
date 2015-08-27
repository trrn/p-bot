# vim:ts=2 sw=2 ts=2 et:
BEGIN_DELIM = '__BEGIN__'
END_DELIM = '__END__'
MATCHED_QUOTE = '*'

class Markov
  constructor: ->
    @seqs = []

  study: (morphemes) ->
    if morphemes.length >= 3
      @seqs = @seqs.concat(morphemes[i..i+2] for i in [0..morphemes.length-3])

  _back1: (mor1) ->
    arr = (seq[seq.length-2] for seq in @seqs when seq[seq.length-1] is mor1)
    arr[Math.floor(Math.random() * arr.length)]

  _back2: (mor1, mor2) ->
    arr = (seq[seq.length-3] for seq in @seqs when seq[seq.length-2] is mor1 and seq[seq.length-1] is mor2)
    arr[Math.floor(Math.random() * arr.length)]

  _next1: (mor1) ->
    arr = (seq[1] for seq in @seqs when seq[0] is mor1)
    arr[Math.floor(Math.random() * arr.length)]

  _next2: (mor1, mor2) ->
    arr = (seq[2] for seq in @seqs when seq[0] is mor1 and seq[1] is mor2)
    arr[Math.floor(Math.random() * arr.length)]

  compose: ->
    arr = []
    mor1 = BEGIN_DELIM
    mor2 = @_next1 mor1
    while mor2 isnt END_DELIM
      arr.push mor2
      [mor1, mor2] = [mor2, @_next2(mor1, mor2)]
    arr

  search: (keyword) ->
    matched_seqs = (seq for seq in @seqs when seq[1] is keyword)
    unless matched_seqs.length
      arr = @compose()
      arr.push " (#{MATCHED_QUOTE}#{keyword}#{MATCHED_QUOTE} not found)"
      return arr

    seq = matched_seqs[Math.floor(Math.random() * matched_seqs.length)]

    # backward
    mor1 = seq[0]
    mor2 = seq[1] # keyword
    arr = [ mor2 ]
    while mor1 isnt BEGIN_DELIM
      arr.unshift mor1
      [mor1, mor2] = [@_back2(mor1, mor2), mor1]

    # forward
    mor1 = arr[arr.length-1]
    mor2 = @_next2(arr[arr.length-2] || BEGIN_DELIM, arr[arr.length-1])
    while mor2 isnt END_DELIM
      arr.push mor2
      [mor1, mor2] = [mor2, @_next2(mor1, mor2)]

    escaped = keyword.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")
    return (e.replace(///(#{escaped})///, " #{MATCHED_QUOTE}$1#{MATCHED_QUOTE} ") for e in arr)

module.exports = Markov
