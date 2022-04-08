const { createServer } = require("http");
const { Server } = require("socket.io");

const httpServer = createServer()

const io = new Server(httpServer, { /* options */ });

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
    
    
    socket.on("userLogin", (userID) => {
        io.emit("userLogin", userID)
    })

})

io.of("/signup").on("connection", socket => {

    socket.on("userSignUp", user => {
        io.emit("userSignUp", user)
    })

})

console.log("runnin on port:", process.env.PORT);
httpServer.listen(process.env.PORT);