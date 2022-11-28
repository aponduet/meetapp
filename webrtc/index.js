
const { io } = require("socket.io-client");
const socket = io("http://localhost:3000");
// const webrtc = require("wrtc");
// import adapter from 'webrtc-adapter';
const {RTCPeerConnection} = require("webrtc-adapter");

//States of the App
// class States{
//     constructor(
//         clientList, conenctions,senderlist){
//           this.senderlist = [];
//         this.clientList = [];
//         this.conenctions = [];
//     }
// }
// var appStates = new States(); //working as memory

var senderlist = [];
var clientList = [];
var conenctions = [];
var pc;


  
  // Connect to Socket Server
  socket.on("connect", () => {
    if (socket.connected) {
        console.log("Socket Server Connected Successfully"); 
        console.log(`Socket id :${socket.id}`); 
        //send home server info to socket server
        const serverInfo ={
        roomId: 5555,
        name: 'Home Server',
        serverId: `SID@@${new Date().getTime()}`,
        serverSocketId: socket.id,
        role: 'server',
        }
        socket.emit('joinServer', serverInfo);
        console.log(serverInfo); 
    }
  });
  //Receive Offer From Client
  socket.on('offer', (response)=>{
    console.log(`Offer is received : ${response}`);
    console.log(`Receiver Id is  : ${response.receiverId}`);
    var newConnectionId = `CIS@@${new Date().getTime()}`;
    //Register to clientList
    var newClient = {
        clientId : response.receiverId,
        clientSocketId : response.receiverSocketId,
        clientName : response.receiverName,
        clientRole : response.receiverRole,
        connectionIdAtServer :  newConnectionId , //indicate the position of client in connection list
        connectionIdAtClient : response.connectionIdAtClient,//indicate the position of client in connection list
        clientStream : '',
    }
    //
   clientList.push(newClient);


    //Register to Connections List
    var newConnection = {
        receiverName : response.receiverName,
        senderName : '',
        receiverId : response.receiverId,
        receiverSocketId : response.receiverSocketId,
        senderId : response.senderId ,
        receiverRole : response.receiverRole,
        senderRole : '',
        connectionIdAtServer : newConnectionId,
        connectionIdAtClient : response.connectionIdAtClient,
        connectionType : response.connectionType,
        pc : '',
        receiverStream : '',
        senderStream : '',
    }
   conenctions.push(newConnection);
    console.log(`Connections List  : ${conenctions[0].connectionIdAtServer}`);
    console.log(`Client List  : ${clientList[0].connectionIdAtServer}`);

    //************ Create Peer Connection ************* */
    
      async function createPeerConnection() {
        console.log(  RTCPeerConnection())
        
        
        const index =conenctions.findIndex((item) => newConnectionId == item.connectionIdAtServer);
         var peer =  new RTCPeerConnection();
      
       peer.ontrack = (e) => {
            const streamIndex =clientList.findIndex((item) => newConnectionId === item.connectionIdAtServer);
           clientList[streamIndex].clientStream = e.streams[0];
        };
      
        // const sdpDesc = {
        //   type: "offer",
        //   sdp: response.offerSdp,
        // };
        console.log(`sdp is : ${response.offerSdp}`)
        const desc = new RTCSessionDescription({
          type: "offer",
          sdp: response.offerSdp,
        });
        //check
        console.log(`Peer connection : ${pc.connectionState}`)
        await pc.setRemoteDescription(desc);
        //if connection is secondary
        if (response.connectionType == 'secondary') {
            const clientIndex =clientList.findIndex((item) => item.connectionIdAtServer === response.connectionIdAtServer);
           clientList[clientIndex].clientStream
      .getTracks()
      .forEach((track) =>peer.addTrack(track,clientList[clientIndex].clientStream));
        }
        const answer = await peer.createAnswer({
            'offerToReceiveAudio':
                1, //May be unneccessary in this case, server not sending own stream
            'offerToReceiveVideo': 1
          });
        await peer.setLocalDescription(answer);
        const answerSdp =pc.localDescription.sdp;
        //Send Answer to Receiver
        socket.emit('answer', {
            session: answerSdp,
            receiverId:conenctions[index].receiverId,
            receiverSocketId:
           conenctions[index].receiverSocketId,
            connectionIdAtServer:
           conenctions[index].connectionIdAtServer,
            connectionIdAtClient:
           conenctions[index].connectionIdAtClient,
            responseType: 'answer',
            connectionType:
           conenctions[index].connectionType,
          }, )

          //check ICE Connection State
         pc.oniceconnectionstatechange = e =>{
            console.log(`ICE State is: ${e}`);
            console.log(`ICE State is: ${pc.iceConnectionState}`);
          }
          //check PEER Connection State
         pc.onconnectionstatechange = e =>{
            console.log(`Peer Connection State is: ${e}`);
            console.log(`Peer Connection State is: ${pc.connectionState}`);
            if (e = 'connected' && response.connectionType == 'primary') {
              const clientIndex =clientList.findIndex((item) => item.connectionIdAtServer == newConnectionId);
              const item = {
                connectionIdAtServer:clientList[clientIndex].connectionIdAtServer,
                clientId:clientList[clientIndex].clientId,
                clientName:clientList[clientIndex].clientName,
                clientRole:clientList[clientIndex].clientRole,
                };
               senderlist.push(item);

              socket.emit("allClients", {
                clientList:senderlist,
                responseType: 'clientList',
                receiverId:clientList[clientIndex].clientId,
                receiverSocketId:clientList[clientIndex].clientSocketId,
              })
            }
          }
          //Send Ice Candidates to Receiver
         pc.onicecandidate = e =>{
            if (e.candidate) {
                socket.emit('serverIceCandidate' , {
                candidate : e.candidate.candidate,
                sdpMid : e.candidate.sdpMid,
                sdpMLineIndex : e.candidate.sdpMLineIndex,
                })
              }
          }
      }

      //Call Create Connection
      createPeerConnection();
  });

  //If Socket Disconnected
  socket.on("disconnect", () => {
    console.log(`Disconnected Id is: ${socket.id}`); 
  });

  //************* Socket Connection Done ************** */
