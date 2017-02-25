listURL = 'https://raw.githubusercontent.com/pirate/sites-using-cloudflare/master/sorted_unique_cf.txt' #noqa
# listURL = 'sorted_unique_cf.txt' #noqa

String::matchAllWithIndexes = (match) ->
  matchArr = []
  if Array.isArray(match)
    matchArr = match
  else if typeof match is 'string'
    matchArr = match.split ''
  else
    throw new TypeError("Expected Array or String, got '#{typeof match}'")
  
  return {matches: false} if matchArr.length > this.length
  
  arr = this.split ''
  
  exact = true
  indexes = []
  j = 0
  for c, i in arr
    if c is matchArr[j]
      indexes.push i
      if ++j is matchArr.length
        return {matches: true, exact: exact, indexes: indexes}
    else if j > 0
      exact = false
  return {matches: false}


domains = []
allDomainsRange = []
$(document).ready ->
  $('#searchbox').on 'keyup change paste', searchboxChanged
  
  console.log 'Loading domains...'
  $.ajax
    type: 'GET'
    url: listURL
    data: {}
    progress: (e) ->
      if e.lengthComputable
        percentComplete = e.loaded / e.total
        console.log percentComplete
    success: (data) ->
      domains = data.split '\n'
      allDomainsRange = [0...domains.length]
      console.log 'Done'



lastSearch = ''
lastResults = {exact: [], partial: [], all: []}
searchboxChanged = (evnt) ->
  search($(this).val())
    .catch((e) -> console.log e)
    .then (r) ->
      lastResults = r
      updateList(r)

search = (query) ->
  return new Promise((resolve, reject) ->
    searchScope = []
    if lastSearch.length > 0 and query.startsWith lastSearch
      searchScope = lastResults.all
    else
      searchScope = allDomainsRange
    
    results = {exact: [], partial: [], all: []}
    
    for i in searchScope
      match = domains[i].matchAllWithIndexes(query)
      continue unless match.matches
      results.all.push i
      if match.exact
        results.exact.push {domain: i, start: match.indexes[0], end: match.indexes[match.indexes.length - 1]} #noqa
      else
        results.partial.push {domain: i, indexes: match.indexes}
    
    lastSearch = query
    resolve results
    return #Block auto-return
  )

updateList = (results) ->
  exactCount = results.exact.length
  if exactCount > 5
    eremain = exactCount - 5
    exactCount = 5
  
  partialCount = results.partial.length
  if partialCount > 5
    premain = partialCount - 5
    partialCount = 5
  
  exacts = ''
  for i in [0...exactCount]
    e = results.exact[i]
    domain = domains[e.domain]
    # TODO: Add match highlighting (e.start)
    # li = domain.lastIndexOf('.') #TODO: Add domain highlighting
    exacts += "<li><span class=\"http\">http://</span><span class=\"main\">#{domain}</span></li>" # TODO: Add domain highlighting: "<span class=\"domain\">.com</span>" #noqa
  
  partials = ''
  for i in [0...partialCount]
    p = results.partial[i]
    domain = domains[p.domain]
    # TODO: Add match highlighting
    # li = domain.lastIndexOf('.') #TODO: Add domain highlighting
    partials += "<li><span class=\"http\">http://</span><span class=\"main\">#{domain}</span></li>" # TODO: Add domain highlighting: "<span class=\"domain\">.com</span>" #noqa
  
  $('#results .section.exact .items').empty().append(exacts)
  $('#results .section.partial .items').empty().append(partials)
