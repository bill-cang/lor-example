local authRouter = require("app.routes.auth")
local todoRouter = require("app.routes.todo")
local errorRouter = require("app.routes.error")
local aboutFun = require("app.routes.aboutFUn")
local abUser = require("app.routes.aboutUser")

return function(app)
    app:use("/auth", authRouter())
    app:use("/todo", todoRouter())
    app:use("/error", errorRouter())
    app:use("/abf",aboutFun())
    app:use("/ur",abUser())

    app:get("/", function(req, res, next)
        local data = {
            name =  req.query.name or "lor",
            desc =   req.query.desc or 'a framework of lua based on OpenResty'
        }
        res:render("welcome", data)
    end)
end

