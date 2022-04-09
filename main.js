const { createClient } = require("redis")
const { Server } = require("socket.io")
const { createAdapter } = require("@socket.io/redis-adapter")
const { createServer } = require("http");
// const { Server } = require("socket.io");
const redisURL = process.env.REDIS_URL
const port = process.env.PORT


const httpServer = createServer()

const io = new Server(httpServer, { /* options */ });
// const io = new Server()
const pubClient = createClient({ url: redisURL })
const subClient = pubClient.duplicate()

io.on("connection", (socket) => {
    socket.on("incomingMessage", (msg, ack) => {
        socket.broadcast.emit(msg.to, msg)
        ack()
    })

    socket.on("userLogout", async userID => {
        await socket.broadcast.emit("userLogout", userID)
        await socket.disconnect()
    })

    socket.on("readMessage", data => {
        socket.broadcast.emit("messageHasBeenRead", data)
    })

});

io.of("/login").on("connection", socket => {

    socket.on("someone connected", id => {
        console.log(id);
    })

    socket.on("userLogin", (userID) => {
        io.emit("userLogin", userID)
    })

})

io.of("/signup").on("connection", socket => {
    socket.on("userSignUp", user => {
        io.emit("userSignUp", user)
    })

})

Promise.all([pubClient.connect(), subClient.connect]).then(() => {
    io.adapter(createAdapter(pubClient, subClient))
    console.log("running on port:", port);
    // io.listen(port)
    httpServer.listen(port);

})


// console.log("runnin on port:", port);