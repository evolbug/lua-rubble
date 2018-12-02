--[[
   evolbug 2018, MIT License
   lua-rubble: Rust-like struct-trait-impl system
]]--

function struct (members)
   assert(type(members)=='table', 'must use table for call')
   return setmetatable({impls={}, traits={}}, {
      __index = {
         impl = function(self, methods)
            assert(type(methods)=='table', 'must use table for methods')
            assert(#methods == 0, 'only named members allowed')
            for k,v in pairs(methods) do
               assert(type(k) == 'string', 'name must be a string')
               assert(type(v) == 'function', 'not a method')
               assert(not self.impls[k], 'method '..k..' already defined')
               self.impls[k] = v
            end
         end
      };

      __call=function(self, init)
         assert(type(init)=='table', 'must use table for init')
         assert(#init == 0, 'only named members allowed')
         for key,value in pairs(init) do
            assert(members[key], 'initializing nonexistent field '..key)
            assert(type(value) == members[key], "type mismatch for member "..key..' expected:'..members[key]..' got:'..type(value))
         end
         return setmetatable(init, {
            __index = self.impls,
            __newindex = function(self, key, value)
               assert(members[key], "setting nonexistent member "..key)
               assert(type(value) == members[key], "type mismatch for member "..key..' expected:'..members[key]..' got:'..type(value))
               self[key] = value
            end
         })
      end;

      __newindex = function(self, key, value)
         error('struct definitions are immutable')
      end
   })
end

function trait (members)
   assert(type(members)=='table', 'must use table for call')
   return setmetatable(members, {
      __index = {
         impl = function (self, struct)
            return function(methods)
               assert(type(methods)=='table', 'must use table for methods')
               assert(#methods == 0, 'only named members allowed')
               for k,v in pairs(self) do
                  assert(methods[k], 'must implement method '..k)
                  assert(type(methods[k]) == 'function', 'method '..k..' not a function')
               end
               for k,v in pairs(methods) do
                  assert(type(k) == 'string', 'name must be a string')
                  assert(type(v) == 'function', 'not a method')
                  assert(self[k], 'method not specified in trait')
                  assert(not struct.impls[k], 'method '..k..' already defined')
                  struct.impls[k] = v
               end
               struct.traits[self] = true
            end
         end
      };
      __call=function(self, init)
         assert(type(init)=='table', 'must use table for init')
         assert(#init == 0, 'only named members allowed')
         for k,v in pairs(init) do
            assert(members[k], 'initializing nonexistent field')
         end
         return setmetatable(init, {
            __index = self.impls,
            __newindex = function(self, key, value)
               assert(members[key], "setting nonexistent member "..key)
               assert(type(value) == members[key], "type mismatch for member")
               self[key] = value
            end
         })
      end;

      __newindex = function(self, key, value)
         error('trait definitions are immutable')
      end
   })
end
