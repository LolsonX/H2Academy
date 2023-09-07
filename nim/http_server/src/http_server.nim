# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import os
import strutils
import tables
import net
import threadpool

type
  Request = ref object
    socket: Socket
    content: string

proc readRequest(req: Request): Request =
  while true:
    var buffer = ""
    req.socket.readLine(buffer)
    if buffer.strip() == "":
      break
    req.content.add(buffer)
    req.content.add("\n")
  return req

proc handleRequest(req: Request) =
  let response = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\nHello, Nim!\r\n"
  req.socket.send(response)

proc processConnection(client: Socket) {.thread.} =
  var request = readRequest(Request(socket: client))
  handleRequest(request)
  request.socket.close()

proc startServer(port: int) =
  let socket = newSocket()
  socket.bindAddr(Port(port))
  socket.listen()
  echo "Server started at http://localhost:", port

  var client: Socket
  var address = ""
  while true:
    socket.acceptAddr(client, address)
    spawn processConnection(client)

when isMainModule:
  let port = 8088  # You can change this to the desired port number.
  startServer(port)
