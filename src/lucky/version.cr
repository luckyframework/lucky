module Lucky
  macro set_version
    VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify.downcase }}
  end

  set_version
end
