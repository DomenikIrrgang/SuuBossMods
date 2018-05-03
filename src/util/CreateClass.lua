function CreateClass()
    local newClass = {}
    newClass.__index = newClass

    setmetatable(newClass, {
        __call = function (cls, ...)
          return cls.new(...)
        end,
    })
    return newClass
end