local lumiere = require("lumiere.lumiere")

local M = {}

local IDENTITY = vmath.matrix4()
local PREDICATE = nil

function M.init(strength)
    STRENGTH = vmath.vector4(strength or 32, 0, 0, 0)
    PREDICATE = render.predicate({ hash("rain") })
end

function M.final()
end

function M.apply(input)
    local resolution = lumiere.resolution()
    local constants = render.constant_buffer()
    constants.time = lumiere.time()
    constants.resolution = vmath.vector4(resolution.x / resolution.y, 1.0, 1.0, 1.0)

    render.set_view(IDENTITY)
    render.set_projection(IDENTITY)
    render.clear({ [render.BUFFER_COLOR_BIT] = lumiere.clear_color(), [render.BUFFER_DEPTH_BIT] = 1 })
    render.enable_texture(0, input, render.BUFFER_COLOR_BIT)
    render.draw(PREDICATE, { constants = constants })
    render.disable_texture(0)
end

return M
