package remote
{
    import com.assukar.airong.utils.Singleton;
    import com.assukar.airong.utils.Utils;

    import flash.events.ProgressEvent;
    import flash.events.ServerSocketConnectEvent;
    import flash.net.ServerSocket;
    import flash.net.Socket;
    import flash.utils.ByteArray;

    public class LocalServerSocket
    {

        static public var ME:LocalServerSocket;

        function LocalServerSocket()
        {
            Singleton.enforce(ME);
        }


        private var serverSocket:ServerSocket;

        public function start():void
        {
            serverSocket = new ServerSocket();
            serverSocket.bind(8888, "192.168.100.26");
            serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, onConnect);
            serverSocket.listen();

            Utils.wraplog("Bound to: " + serverSocket.localAddress + ":" + serverSocket.localPort);
        }


        private var clientSocket:Socket;

        private function onConnect(e:ServerSocketConnectEvent):void
        {
            clientSocket = e.socket;
            clientSocket.addEventListener(ProgressEvent.SOCKET_DATA, onClientSocketData);

            Utils.wraplog("new connection from " + clientSocket.remoteAddress + ":" + clientSocket.remotePort);
        }

        private function onClientSocketData(e:ProgressEvent):void
        {
//            Utils.print("receiveData: " + e.bytesLoaded +"/" + e.bytesTotal);

            try
            {

                var bytes:ByteArray = new ByteArray();
                clientSocket.readBytes(bytes, 0, clientSocket.bytesAvailable);

                bytes.position = 0;
                Utils.wraplog("onClientSocketData: " + bytes.readObject());
            }
            catch (err:Error)
            {
                Utils.wraplog( err.message);
            }

        }


        public function send(data:Array):void
        {
            try
            {
                if (clientSocket != null && clientSocket.connected)
                {
                    clientSocket.writeObject(data);
                    clientSocket.flush();

                    Utils.wraplog("Sent message to " + clientSocket.remoteAddress + ":" + clientSocket.remotePort);
                }
                else Utils.wraplog("No socket connection");
            }
            catch (err:Error)
            {
                Utils.wraplog(err.message);
            }
        }


    }
}
