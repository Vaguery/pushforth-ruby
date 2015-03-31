module PushForth
  class Dictionary
    attr_accessor :contents

    def initialize(hash = {})
      @contents = hash
    end

    def set(key,value)
      value = value.clone if value.kind_of?(Array) || value.kind_of?(Dictionary)
      contents[key] = value
    end

    def get(key)
      return contents[key] || Error.new("key not found")
    end

    def eql?(other)
      return @contents.eql?(other.contents)
    end

    def keys
      @contents.keys
    end

    def clone
      copy = Dictionary.new()
      self.keys.each do |k|
        safe_key = deep_copy(k)
        safe_val = deep_copy(@contents[k])
        copy.contents[safe_key] = safe_val
      end
      return copy
    end
  end
end