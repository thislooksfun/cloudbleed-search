// Generated by CoffeeScript 1.10.0
var allDomainsRange, domains, lastResults, lastSearch, listURL, search, searchboxChanged, updateList;

listURL = 'https://raw.githubusercontent.com/pirate/sites-using-cloudflare/master/sorted_unique_cf.txt';

String.prototype.matchAllWithIndexes = function(match) {
  var arr, c, exact, i, indexes, j, k, len, matchArr;
  matchArr = [];
  if (Array.isArray(match)) {
    matchArr = match;
  } else if (typeof match === 'string') {
    matchArr = match.split('');
  } else {
    throw new TypeError("Expected Array or String, got '" + (typeof match) + "'");
  }
  if (matchArr.length > this.length) {
    return {
      matches: false
    };
  }
  arr = this.split('');
  exact = true;
  indexes = [];
  j = 0;
  for (i = k = 0, len = arr.length; k < len; i = ++k) {
    c = arr[i];
    if (c === matchArr[j]) {
      indexes.push(i);
      if (++j === matchArr.length) {
        return {
          matches: true,
          exact: exact,
          indexes: indexes
        };
      }
    } else if (j > 0) {
      exact = false;
    }
  }
  return {
    matches: false
  };
};

domains = [];

allDomainsRange = [];

$(document).ready(function() {
  $('#searchbox').on('keyup change paste', searchboxChanged);
  console.log('Loading domains...');
  return $.ajax({
    type: 'GET',
    url: listURL,
    data: {},
    progress: function(e) {
      var percentComplete;
      if (e.lengthComputable) {
        percentComplete = e.loaded / e.total;
        return console.log(percentComplete);
      }
    },
    success: function(data) {
      var k, ref, results1;
      domains = data.split('\n');
      allDomainsRange = (function() {
        results1 = [];
        for (var k = 0, ref = domains.length; 0 <= ref ? k < ref : k > ref; 0 <= ref ? k++ : k--){ results1.push(k); }
        return results1;
      }).apply(this);
      return console.log('Done');
    }
  });
});

lastSearch = '';

lastResults = {
  exact: [],
  partial: [],
  all: []
};

searchboxChanged = function(evnt) {
  return search($(this).val())["catch"](function(e) {
    return console.log(e);
  }).then(function(r) {
    lastResults = r;
    return updateList(r);
  });
};

search = function(query) {
  return new Promise(function(resolve, reject) {
    var i, k, len, match, results, searchScope;
    searchScope = [];
    if (lastSearch.length > 0 && query.startsWith(lastSearch)) {
      searchScope = lastResults.all;
    } else {
      searchScope = allDomainsRange;
    }
    results = {
      exact: [],
      partial: [],
      all: []
    };
    for (k = 0, len = searchScope.length; k < len; k++) {
      i = searchScope[k];
      match = domains[i].matchAllWithIndexes(query);
      if (!match.matches) {
        continue;
      }
      results.all.push(i);
      if (match.exact) {
        results.exact.push({
          domain: i,
          start: match.indexes[0],
          end: match.indexes[match.indexes.length - 1]
        });
      } else {
        results.partial.push({
          domain: i,
          indexes: match.indexes
        });
      }
    }
    lastSearch = query;
    resolve(results);
  });
};

updateList = function(results) {
  var domain, e, eremain, exactCount, exacts, i, k, l, p, partialCount, partials, premain, ref, ref1;
  exactCount = results.exact.length;
  if (exactCount > 5) {
    eremain = exactCount - 5;
    exactCount = 5;
  }
  partialCount = results.partial.length;
  if (partialCount > 5) {
    premain = partialCount - 5;
    partialCount = 5;
  }
  exacts = '';
  for (i = k = 0, ref = exactCount; 0 <= ref ? k < ref : k > ref; i = 0 <= ref ? ++k : --k) {
    e = results.exact[i];
    domain = domains[e.domain];
    exacts += "<li><span class=\"http\">http://</span><span class=\"main\">" + domain + "</span></li>";
  }
  partials = '';
  for (i = l = 0, ref1 = partialCount; 0 <= ref1 ? l < ref1 : l > ref1; i = 0 <= ref1 ? ++l : --l) {
    p = results.partial[i];
    domain = domains[p.domain];
    partials += "<li><span class=\"http\">http://</span><span class=\"main\">" + domain + "</span></li>";
  }
  $('#results .section.exact .items').empty().append(exacts);
  return $('#results .section.partial .items').empty().append(partials);
};

//# sourceMappingURL=main.js.map
