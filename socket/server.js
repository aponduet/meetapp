const express = require('express');
const cors = require('cors');
const app = express();
const http = require('http');
const server = http.createServer(app);
const io = require("socket.io")(server);
require('dotenv').config();
//const port = process.env.PORT || 3000;
const port = 5000;
app.use(express.json());
app.use(cors());
app.get('/', (req, res) => {
    res.send( 'Hello Sohel');
  });

class Info{
    constructor(serverId,serverSocketId,roomId,serverName,serverRole){
        this.serverId = serverId;
        this.serverSocketId = serverSocketId;
        this.roomId = roomId;
        this.serverName = serverName;
        this.serverRole = serverRole;
    }
}
const serverInfo = new Info();
//
io.on("connection",  (socket)=> {
    // **************** Socket to Server ***************************
    // **************** Socket to Server ***************************
    // **************** Socket to Server ***************************
    //console.log(io.sockets.adapter.rooms);
    //console.log(io);
    //  console.log(socket.id);

    socket.on("joinServer", (data) => {
        console.log("joinServer event is called");
        //server socketId may change any time , so we will not be dependent on the id has been gotten first entry.
        //Lets try to find server socketId which is active right now.
       function setValue(){
        serverInfo.serverId = data.serverId;
        serverInfo.serverSocketId = data.serverSocketId;
        serverInfo.roomId = data.roomId;
        serverInfo.serverName = data.name;
        serverInfo.serverRole = data.role;
        };
    
        socket.join(data.roomId); 
        setValue(); 
        console.log(`Server Socket ID is : ${serverInfo.serverSocketId}`);
        // Call socket server
    });


    // **************** Socket to Clietn ***************************
    // **************** Socket to Clietn ***************************
    // **************** Socket to Clietn ***************************

    socket.on("joinClient", (data, callback) => {
        console.log("join client event is called")
        //server socketId may change any time , so we will not be dependent on the id has been gotten first entry.
        //Lets try to find server socketId which is active right now.
        if (serverInfo.serverId === "null") {
            callback({
                serverId : '0',
            })
        } else {
            callback({
                serverId : serverInfo.serverId,
                roomId : serverInfo.roomId,
                serverName : serverInfo.serverName,
                serverRole : serverInfo.serverRole,
            })
            
        }
    });



    

    

    // socket.on("newConnect", (roomId, callback) => {
    //     //convert Socket.io map to Array and separate users and room names. https://logfetch.com/js-socketio-active-rooms/
        
    //         const arr = Array.from(io.sockets.adapter.rooms);
    //         // Filter rooms whose name exist in set:
    //         // ==> [['room1', Set(2)], ['room2', Set(2)]]
    //         const filtered = arr.filter(room => !room[1].has(room[0]));
    //         const filteredRoom = filtered.filter(room => room[0]==roomId);
    //         const roomUsers = filteredRoom[0][1];
    //         const value = roomUsers.values(); // Values Set
    //         const a = Array.from(value);//Convert Set to Array
    //         //const res = roomUsers.map(i => i[0]);
    //         //const [first] = roomUsers;
    //         console.log(a);
    //     callback({ originId: socket.id, destinationIds: a });
    // })



    socket.on("offer", (data) => {
        console.log('OfferForServer event is called');
        //send Offer to server
        io.to(serverInfo.serverSocketId).emit('offer', data);
    })
    

    socket.on("answer", (data) => {
        //send answerSdp to Receiver
        console.log('AnswerFromServer event is called');
        console.log(`Answer is : ${data}`);
        io.to(data.receiverSocketId).emit('answer', data);
    })

    socket.on("serverIceCandidate", (data) => {
        //send answerSdp to Receiver
        console.log('IceCandidateFromServer event is called');
        console.log(`ICE REsponse is : ${data}`);
        io.to(data.receiverSocketId).emit('serverIceCandidate', data);
    })

    socket.on("clientIceCandidate", (data) => {
        //send answerSdp to Server
        console.log('IceCandidateFromClient event is called');
        io.to(serverInfo.serverSocketId).emit('clientIceCandidate', data);
    })
    //send all clients to Receiver
    socket.on("allClients", (data) => {
        console.log('AllClientList event is called');
        console.log(`All Clients are : ${data}`);
        io.to(data.receiverSocketId).emit('allClients', data);
    })
    //Notify all about new client
    socket.on("newClient", (data) => {
        console.log('newClientAdded event is called');
        console.log(`new client is : ${data}`);
        socket.broadcast.emit("newClient", data);
    })


    // socket.on("sendCandidate", (data) => {
    //     console.log("sendCandidate event is called.");
    //     var socketId = {
    //         originId: data.socketId.destinationId,
    //         destinationId: data.socketId.originId
    //     }
    //     //console.log(data);
    //     io.to(data.socketId.destinationId).emit("receiveCandidate", { candidate: data.candidate, socketId: socketId });
    // })

    // socket.on("disconnect", () => {
    //     console.log("Disconnect event is called.");
    //     io.sockets.emit("userDisconnected", socket.id);
    //     //console.log("Client disconnected", socket.id);
    // })

    

    //If WebRTC connection Disconnected by user
    socket.on("userDisconnected", (data) => {
        console.log("Disconnect event is called.");
        socket.broadcast.emit("userDisconnected", data);
        console.log("Client disconnected", data);
    })
})

server.listen(port, () => console.log(`Server Listening on port ${port}`));