-- nofollow.lua
-- Automatically adds rel="nofollow" to all external links

function Link(elem)
  if elem.target and elem.target:match("^https?://") then
    -- Add nofollow to attributes
    if elem.attributes then
      elem.attributes.rel = "nofollow"
    end
  end
  return elem
end
