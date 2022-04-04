const { createServer } = require("http");
const { Server } = require("socket.io");

const httpServer = createServer()

const io = new Server(httpServer, { /* options */ });

io.on("connection", (socket) => {

    socket.on("incomingMessage", (msg) => {
        io.emit(msg.to, msg)
    })

    socket.on("userLogout", userID => {
        socket.broadcast.emit("userLogout", userID)
    })

});

io.of("/login").on("connection", socket => {
    
    
    socket.on("userLogin", (userID) => {
        io.emit("userLogin", userID)
    })

})


httpServer.listen(8000);