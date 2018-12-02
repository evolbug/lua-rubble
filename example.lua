require 'rubble'

vector2 = struct {
   x = "number",
   y = "number",
}

vector2: impl {
   length = function(self)
      return math.sqrt(self.x * self.x + self.y * self.y)
   end;
}

add = trait {
   add = function(self, other)end
}


add: impl (vector2) {
   add = function(self, other)
      return vector2 { x = self.x + other.x, y = self.y + other.y }
   end;
}

local v1 = vector2{x=1, y=2}
local v2 = vector2{x=2, y=1}
local v3 = v1:add(v2)

print(v3.x, v3.y, v3:length())