package controller
{
    import com.assukar.airong.error.AssukarError;
    import com.assukar.airong.utils.Singleton;
    import com.assukar.airong.utils.Utils;
    import com.assukar.airong.utils.composer.ComposerDataAction;
    import com.assukar.airong.utils.composer.ComposerDataObject;

    import flash.events.ProgressEvent;
    import flash.events.ServerSocketConnectEvent;
    import flash.net.Socket;
    import flash.net.registerClassAlias;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;

    import remote.LocalServerSocketChannel;

    public class LocalServerSocketController
    {

        static public var ME:LocalServerSocketController;

        function LocalServerSocketController()
        {
            registerClassAlias("com.assukar.airong.utils.composer", ComposerDataObject);

            Singleton.enforce(ME);
        }

        private var channel:LocalServerSocketChannel = null;

        private function createChannel():LocalServerSocketChannel
        {
            if (channel) throw AssukarError("channel already created");
            channel = new LocalServerSocketChannel();
            return channel;
        }

        public function initiate(localPort:int = 0, localAddress:String = "0.0.0.0"):void
        {
            createChannel();
            channel.start(localPort, localAddress);
        }

        private var clientSocket:Socket;

        public function channelConnect(e:ServerSocketConnectEvent):void
        {
            clientSocket = e.socket;
            clientSocket.addEventListener(ProgressEvent.SOCKET_DATA, socketData);

            Utils.print("new connection from " + clientSocket.remoteAddress + ":" + clientSocket.remotePort);
        }


        private var socketDataBytes:ByteArray = new ByteArray();

        private function socketData(e:ProgressEvent):void
        {
            socketDataBytes.position = 0;
            clientSocket.readBytes(socketDataBytes, socketDataBytes.bytesAvailable, clientSocket.bytesAvailable);

            var temp:ByteArray = new ByteArray();
            temp.writeObject(socketDataBytes);

            var result:ComposerDataObject;
            try
            {
                temp.position = 0;
                var resultTemp:ByteArray = temp.readObject() as ByteArray;
                resultTemp.position = 0;
                result = resultTemp.readObject() as ComposerDataObject;
            }
            catch (err:Error)
            {
                Utils.print("trying do decode data...");
                return;
            }

//            Utils.print("decode completed: " + result);
//            Utils.print("decode completed");
            socketDataBytes.clear();

            processData(result);

        }


        private var requestCallback:Dictionary = new Dictionary();

        public function request(data:ComposerDataObject, callback:Function = null):void
        {
            try
            {
                if (clientSocket != null && clientSocket.connected)
                {
                    clientSocket.writeObject(data);
                    clientSocket.flush();

                    requestCallback[data.action] = callback;

//                    Utils.print("Sent message to " + clientSocket.remoteAddress + ":" + clientSocket.remotePort);
                }
                else Utils.print("No socket connection");
            }
            catch (err:Error)
            {
                Utils.print(err.message);
            }
        }


        private function processData(result:ComposerDataObject):void
        {
            switch (result.action)
            {
                case ComposerDataAction.REFRESH:
                    if (requestCallback[result.action]) requestCallback[result.action](result.data as XML);
                    break;
                case ComposerDataAction.SELECT_COMP:
                case ComposerDataAction.UPDATE_PROP_LABEL:
                case ComposerDataAction.COPY_PROP:
                case ComposerDataAction.PAUSE_TOGGLE:
                case ComposerDataAction.DRAW:
                    if (requestCallback[result.action]) requestCallback[result.action](result.data as String);
                    break;
                case ComposerDataAction.GET_PROP_LABEL:
                case ComposerDataAction.CHANGE_PROP:
                    if (requestCallback[result.action]) requestCallback[result.action](result.data as Array);
                    break;
                case ComposerDataAction.APPLY_PROP:
                    if (requestCallback[result.action]) requestCallback[result.action](result.data as Boolean);
                    break;
            }

        }


    }
}
