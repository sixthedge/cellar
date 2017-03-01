import ember from 'ember'

export default ember.Helper.helper ([obja, objb], options={}) ->
  if obja and obja == objb
    string = options.if_true or ''
  else
    string = options.if_false or ''
  string.htmlSafe()
