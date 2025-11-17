"use client"

import React, { useEffect, useRef, useState } from 'react'

export default function TestSpeaking() {

const [status, setStatus] = useState("idle");
  const [log, setLog] = useState<string[]>([]);
  const socketRef = useRef<WebSocket | null>(null);
  const recorderRef = useRef<MediaRecorder | null>(null);
  
  const wsUrl:string = process.env.NEXT_PUBLIC_SPEAKING_WS_URL ?? "ws://localhost:8080/ws/speaking";
  

  const appendLog = (log : string) => {
    setLog((prev) => [...prev, log])
  } 

  const startStreaming = async () => {
    if (socketRef.current && socketRef.current.readyState === WebSocket.OPEN) {
        return;
    }
    setStatus("connecting...");
    const socket = new WebSocket(wsUrl);
    socketRef.current = socket;


    socket.onopen = async () => {
        setStatus("connected, requesting mic...");
        try {
            const stream = await navigator.mediaDevices.getUserMedia({audio: true});
            setStatus("recording");
        
            const recorder = new MediaRecorder(stream, {
                mimeType : "audio/webm;codecs=opus"
            });
            recorderRef.current = recorder;
            recorder.ondataavailable = async (e) => {
                if (e.data.size > 0 && socket.readyState === WebSocket.OPEN) {
                        const buf = await e.data.arrayBuffer(); 
                        socket.send(buf);
                }
            }
            recorder.start(500);
        }
         
        catch (err: any) {
            console.error(err);

            appendLog("[error] Cannot access mic");
        }
    }
    socket.onmessage = async (event) => {
        const text = event.data as string;
        appendLog(text);
    }
    socket.onclose = () => {
        setStatus("closed");
        if (recorderRef.current && recorderRef.current.state !== "inactive")
             recorderRef.current.stop();
        recorderRef.current = null;
        socketRef.current = null;
    }
    socket.onerror = (event) =>  {
      console.error("WS error:", event);
      setStatus("error (check console)");
      appendLog("[error] websocket error");
    }
   };
   const stopStreaming = () => {
    if (recorderRef.current && recorderRef.current.state !== 'inactive') {
        recorderRef.current.stop();
    }
    recorderRef.current = null;
    if (socketRef.current && socketRef.current.readyState === WebSocket.OPEN)
        socketRef.current.close();
    
    socketRef.current = null;
        setStatus("stopped");

    }

    useEffect(() => {
        return () => {
            if (recorderRef.current && recorderRef.current.state !== 'inactive') recorderRef.current.stop();
            if (socketRef.current && socketRef.current.readyState  === WebSocket.OPEN) socketRef.current.close();
        }

    },[])

  return (
   <main className='mt-3 gap-3 relative text-center'>
      <h1 className='relative mt-3'>Speaking WebSocket Test</h1>
      <p>
        Backend WS: <code>{wsUrl}</code>
      </p>
      <p>Status: <strong>{status}</strong></p>

      <div style={{ margin: "10px 0" }}>
        <button  className='dark:border dark:border-amber-50' onClick={startStreaming} style={{ marginRight: 8 }}>
          Start streaming
        </button>
        <button onClick={stopStreaming}>Stop</button>
      </div>

      <h3>Transcript</h3>
      <div
        style={{
          border: "1px solid #ccc",
          padding: 10,
          minHeight: 150,
          whiteSpace: "pre-wrap",
        }}
      >
        {log.map((line, idx) => (
          <div key={idx}>{line}</div>
        ))}
      </div>
    </main>
  ) 
}

