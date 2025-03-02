
RegisterNUICallback("closeMenu", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)