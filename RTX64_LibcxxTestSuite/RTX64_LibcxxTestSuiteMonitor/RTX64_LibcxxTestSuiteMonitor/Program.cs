using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using RTX64MessageBusManaged;
using System.Threading;

namespace ConsoleApplication1
{
    class Program
    {
        static void Main(string[] args)
        {

            while (true)
            {
                int[] channels = { 0, (int)RTMB_KNOWNCHANNEL_LIST.RTMB_CHANNEL_SUBSYSTEM_ACTIVITY };
                int recvChannel;
                RTMB_MESSAGE_TYPE msgType = 0;
                byte[] message = new byte[MessageBusAPIs.MAX_MESSAGE_SIZE];

                RTX64MessageBusManaged.MessageBusAPIs.RtmbRecieve(channels, out msgType, out recvChannel, out message);

                System.IO.StreamWriter log = System.IO.File.AppendText(@"C:\CPPRunLog.txt");
                if (msgType == RTMB_MESSAGE_TYPE.RTMB_TYPE_SUBSYSTEM_EVENT)
                {
                    log.WriteLine(MessageBusAPIs.ByteArrayToSubsystemEventMessage(message));
                }
                else if (msgType == RTMB_MESSAGE_TYPE.RTMB_TYPE_NOTIFY)
                {
                    log.WriteLine(Encoding.ASCII.GetChars(message));
                }

                log.Close();
                Thread.Sleep(100);
            }

        }

    }
}
