listURL = 'https://raw.githubusercontent.com/pirate/sites-using-cloudflare/master/sorted_unique_cf.txt' #noqa
# listURL = 'sorted_unique_cf.txt'

String::matchAllWithIndexes = (match) ->
  
  unless verifyMatchData(this, match)
    return {matches: false}
  
  start = @indexOf(match[0])
  if start is -1
    return {matches: false}
  if match.length is 1
    return {matches: true, exact: true, indexes: [start]}
  
  exact = true
  indexes = [start]
  j = 1
  for i in [start...@length]
    if @[i] is match[j]
      indexes.push i
      if ++j is match.length
        return {matches: true, exact: exact, indexes: indexes}
    else if j > 0
      exact = false
  return {matches: false}

verifyMatchData = (str, match) ->
  unless Array.isArray(match) or typeof match is 'string'
    throw new TypeError("Expected Array or String, got '#{typeof match}'")
  return match.length > 0 and match.length <= str.length
  


domains = []
allDomainsRange = []
$(document).ready ->
  if navigator.userAgent.match(/iPhone|iPad|iPod/i)
    $('main').addClass 'hidden'
    $('#not-supported').removeClass 'hidden'
    return
  
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

# Should be of form {query: String, results: Object}
lastSearches = [{query: '', results: {exact: [], partial: [], all: []}}]
searchboxChanged = (evnt) ->  #noqa
  search($(this).val())
    .catch (e) -> console.log e
    .then  (r) -> updateList(r)

search = (query) ->
  return new Promise((resolve, reject) ->
    
    lastSearch = lastSearches[0]
    
    if query is ''
      results = {exact: [], partial: [], all: [], noQuery: true}
      logSearch query, results
      resolve results
      return
    
    searchScope = []
    if lastSearch.query isnt '' and query.startsWith lastSearch.query
      searchScope = lastSearch.results.all
    else
      # See if the search has been done before, and reuse cached results
      for si, i in lastSearches
        if si.query is query
          results = si.results
          # Move search to top of list
          lastSearches.unshift (lastSearches.splice i, 1)[0]
          resolve results
          return
      
      searchScope = allDomainsRange
    
    results = {exact: [], partial: [], all: [], noQuery: false}
    
    for i in searchScope
      match = domains[i].matchAllWithIndexes(query)
      continue unless match.matches
      results.all.push i
      if match.exact
        results.exact.push {domain: i, start: match.indexes[0], end: match.indexes[match.indexes.length - 1]} #noqa
      else
        results.partial.push {domain: i, indexes: match.indexes}
    
    logSearch query, results
    resolve results
    return #Block auto-return
  )

logSearch = (query, results) ->
  lastSearches.unshift {query: query, results: results}
  if lastSearches.length > 50
    lastSearches.splice 50

updateList = (results) ->
  exactCount = results.exact.length
  if exactCount > 5
    eremain = exactCount - 5
    exactCount = 5
  
  partialCount = results.partial.length
  if partialCount > 5
    premain = partialCount - 5
    partialCount = 5
  
  $('#results').toggleClass 'hidden', exactCount + partialCount is 0
  $('#results .section.exact').toggleClass 'hidden', exactCount is 0
  $('#results  .section.partial').toggleClass 'hidden', partialCount is 0
  $('#no-results').toggleClass 'hidden', (exactCount + partialCount > 0) or results.noQuery
  
  # No point in continuing if there's nothing to display
  return if exactCount + partialCount is 0
  
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
