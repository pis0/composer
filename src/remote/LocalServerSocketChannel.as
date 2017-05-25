package remote
{
    import com.assukar.airong.utils.Utils;
    import controller.LocalServerSocketController;
    import flash.events.ServerSocketConnectEvent;
    import flash.net.ServerSocket;

    public class LocalServerSocketChannel
    {
        function LocalServerSocketChannel()
        {
        }

        private var serverSocket:ServerSocket;

        public function start(localPort:int = 0, localAddress:String = "0.0.0.0"):void
        {
            serverSocket = new ServerSocket();
            serverSocket.bind(localPort, localAddress);
            serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, LocalServerSocketController.ME.channelConnect);
            serverSocket.listen();

            Utils.wraplog("Bound to: " + serverSocket.localAddress + ":" + serverSocket.localPort);
        }


    }
}
