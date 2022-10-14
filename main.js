// const dotenv = require("dotenv")
// dotenv.config({
//     path: ".prod.env"
// })

const { createClient } = require("redis")
const { Server } = require("socket.io")
const { createAdapter } = require("@socket.io/redis-adapter")
const { createServer } = require("http");

const redisURL = process.env.REDIS_URL
const redisPassword = process.env.REDIS_PASSWORD
const port = process.env.APP_PORT
const wsPrefix = process.env.WS_PREFIX

const httpServer = createServer()
const io = new Server(httpServer, { /* options */ });

const pubClient = createClient({ url: redisURL, password: redisPassword })
const subClient = pubClient.duplicate()


io.of(wsPrefix).on("connection", (socket) => {
    socket.on("incomingMessage", (msg, ack) => {
        socket.broadcast.emit(msg.receiver_id.toString(), msg)
    })

    socket.on("userLogout", async userID => {
        await socket.broadcast.emit("userLogout", userID)
        await socket.disconnect()
    })

    socket.on("readMessage", data => {
        let event = `immediateRead${data.sender_id}`
        socket.broadcast.emit(event, data)
    })
    
    socket.on("lateRead", async data => {
        let event = `lateRead${data.sender_id}`
        socket.broadcast.emit(event, data)
    })

});

io.of(wsPrefix+"/login").on("connection", socket => {

    socket.on("someone connected", id => {
    })

    socket.on("userLogin", (userID) => {
        io.of(wsPrefix).emit("userLogin", userID)
    })

})

io.of(wsPrefix+"/signup").on("connection", socket => {
    socket.on("userSignUp", user => {
        io.of(wsPrefix).emit("userSignUp", user)
    })

})

Promise.all([pubClient.connect(), subClient.connect]).then(() => {
    io.adapter(createAdapter(pubClient, subClient))
    console.log("running on port:", port);
    httpServer.listen(port);

})

