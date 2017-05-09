import ember from 'ember'

export default ember.Mixin.create 
  range: ember.computed 'per_page', 'total_records', 'total_pages', 'current_page', ->
    per_page      = @get('per_page')
    total_pages   = @get('total_pages')
    total_records = @get('total_records')
    current_page  = @get('current_page')
    min      = if current_page > 1 then (per_page*(current_page-1) + 1) else 1
    if current_page == total_pages
      if total_records <= (current_page * per_page)
        max = total_records
      else
        max = (current_page * per_page)
    else
        max = (current_page * per_page)
    "Showing #{min} to #{max} of #{total_records} entries"