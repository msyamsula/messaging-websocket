// const { readFileSync } = require("fs");
const { createServer } = require("http");
const { Server } = require("socket.io");

// const httpServer = createServer({
//   key: readFileSync("/path/to/my/key.pem"),
//   cert: readFileSync("/path/to/my/cert.pem")
// });

const httpServer = createServer()

const io = new Server(httpServer, { /* options */ });

io.on("connection", (socket) => {

    socket.on("incomingMessage", (msg) => {
        console.log("emit ", msg.to);
        io.emit(msg.to, msg)
    })

    
});

// io.on("incomingMessage", (msg) => {
//     console.log(msg);
// })

httpServer.listen(8000);