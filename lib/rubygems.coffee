module.exports = RubyGems =
  apiUri: "https://rubygems.org/api/v1"
  
  ajax: (path, options={}) ->
    fetch(path, options)
      .then (response) -> 
        response.json().then (body) ->
          body
      .catch (e) ->
        new Promise (resolve, reject) ->
          resolve {error: "Couldn't find this gem in rubygems.org"}
          
        
  getLatestVersion: (name) ->
    @ajax("#{@apiUri}/versions/#{name}/latest.json")
  
  getGemInfo: (name) ->
    @ajax("#{@apiUri}/gems/#{name}.json")
