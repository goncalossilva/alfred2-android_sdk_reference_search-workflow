($LOAD_PATH << File.expand_path("..", __FILE__)).uniq!

require "rubygems" unless defined? Gem
require "bundle/bundler/setup"
require "alfred"

require "uri"
require "open-uri"
require "json"

REFERENCE_CACHE_DURATION = 7200 # 2 hours

REFERENCE_JS_URL = "http://developer.android.com/reference/lists.js";
XML_REFERENCE_JS_URL = "android-xml-ref.js"

def reference_search(alfred, query)
  return if query.empty?

  results = Array.new
  load_references(alfred).each do |reference|
    results << reference if reference["label"].downcase.include?(query.downcase)
  end

  rank_results(results, query)

  feedback = alfred.feedback
  feedback.add_item({
    :uid      => -1,
    :title    => "Android SDK Reference Search",
    :subtitle => "Search Android SDK docs for #{query}",
    :arg      => "https://developer.android.com/index.html#q=#{URI.escape(query)}"
  })
  i = 0
  results.each do |result|
    url = "https://developer.android.com/#{result['link']}"
    feedback.add_item({
      :uid      => result["id"],
      :title    => result["label"],
      :subtitle => url,
      :arg      => url
    })
    i += 1
    break if i > 10
  end
  puts feedback.to_alfred
end

def load_references(alfred)
  references = load_references_from_cache(alfred)
  if !references
    references = load_references_from_internet
    cache_references(alfred, references)
  end
  references
end

def load_references_from_cache(alfred)
  cache_file = get_cache_file(alfred)
  # Only load cached references if they exist and are not expired.
  if(File.exist?(cache_file) && Time.now - File.ctime(cache_file) < REFERENCE_CACHE_DURATION)
    File.open(cache_file, "rb") { |f| Marshal.load(f) }
  else
    nil
  end
end

def load_references_from_internet
  references = Array.new
  [REFERENCE_JS_URL, XML_REFERENCE_JS_URL].each do |reference_url|
    reference_js_str = open(reference_url).read
    reference_js_str.gsub!(/(^var\s*\w+\s*=)|(;\s*$)/, "") # Remove variable declaration
    reference_js_str.gsub!(/([\w]+):/, '"\1":') # "Quote" keys, making it valid JSON
    references.concat(JSON.parse(reference_js_str))
  end
  references
end

def cache_references(alfred, references)
  File.open(get_cache_file(alfred), "wb") { |f| Marshal.dump(references, f) }
end

def get_cache_file(alfred)
  File.join(alfred.volatile_storage_path, "references")
end

def rank_results(results, query)
  # We replace dashes with underscores so dashes aren't treated as word boundaries.
  query_lower = query.downcase.gsub("-", "_");
  query_part = (query_lower.match(/\w+/) || [""])[0]
  part_prefix_alnum_re = Regexp.new("\\b" + query_part)
  part_exact_alnum_re = Regexp.new("\\b" + query_part + "\\b")

  results.each do |result|
    score = 1.0

    label_lower = result["label"].downcase.gsub("-", "_")
    t = label_lower.rindex(part_exact_alnum_re)
    if t
      parts_after = label_lower[t+1..-1].count(".")
      score *= 200 / (parts_after + 1)
    else
      t = label_lower.rindex(part_prefix_alnum_re)
      if t
        parts_after = label_lower[t+1..-1].count(".")
        score *= 20 / (parts_after + 1)
      end
    end

    result["score"] = score + (result["extraRank"] || 0) * 200
  end

  results.sort! do |a, b|
    if a["score"] != b["score"]
      b["score"] <=> a["score"]
    else
      a["label"] <=> b["label"] # Lexicographical sort if scores are the same.
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  Alfred.with_friendly_error do |alfred|
    alfred.with_rescue_feedback = true
    query = ARGV.join(" ").strip
    reference_search(alfred, query)
  end
end
