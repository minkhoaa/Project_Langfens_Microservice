"use client"

import React, { useEffect, useRef, useState } from 'react'

export default function TestSpeaking() {

const [status, setStatus] = useState("idle");
  const [log, setLog] = useState<string[]>([]);
  const socketRef = useRef<WebSocket | null>(null);
  const recorderRef = useRef<MediaRecorder | null>(null);
  const chunkRef = useRef<Blob[]>([]);
  const streamRef = useRef<MediaStream | null> (null);

  const apiUrl: string =
    process.env.NEXT_PUBLIC_SPEAKING_HTTP_URL ??
    "http://localhost:8090/api/speaking/transcript";  

  const appendLog = (log : string) => {
    setLog((prev) => [...prev, log])
  } 

  const startRecording = async  () => {
    try {
    setStatus("requesting mic...")
    const stream = await navigator.mediaDevices.getUserMedia( { audio: true});
    streamRef.current = stream;

    const recorder = new MediaRecorder(stream, {
      mimeType: "audio/webm;codecs=opus",
    })
    chunkRef.current = [];
    recorder.ondataavailable = (e) => {

      if (e.data.size > 0) { 
        chunkRef.current.push(e.data);
      }
    } 

    recorder.onstop = async () => {
      setStatus("uploading..");
      try {
        const blob = new Blob(chunkRef.current, {
          type: "audio/webm;codecs=opus",
        });

        const form = new FormData();
        form.append("request", blob, "record.webm");
        const res = await fetch(apiUrl, {
          method: "POST",
          body: form
        });
        if (!res.ok) {
            const text = await res.text();
            appendLog("[error] " + text);
            setStatus("error");
            return;
        }

        const data = await res.json();
         if (data.transcript) {
            appendLog("Transcript: " + data.transcript);
            setStatus("done");
          } else if (data.error) {
            appendLog("[error] " + data.error);
            setStatus("error");
          } else {
            appendLog("[warn] No transcript returned");
            setStatus("done");
          }
      }
       catch (err: any) {
          console.error(err);
          appendLog("[error] " + err.message);
          setStatus("error");
      }
      finally {
        if (streamRef.current) {
          streamRef.current.getTracks().forEach((t) => t.stop());
          streamRef.current = null;
        }
        recorderRef.current = null;
      }
    }
    recorder.start();
    recorderRef.current = recorder;
    setStatus("recording");
    appendLog("recording started")
  }
  catch (err: any) {
    console.error(err);
    appendLog("[error] Cannot access mic: " + err.message);
    setStatus("error");
  }
  }
  
  const stopRecording = () => {
    if (!recorderRef.current) return;
    setStatus("stopping...");
    recorderRef.current.stop();
  };


  return (
   <main className='mt-3 gap-3 relative text-center'>
      <h1 className='relative mt-3'>Speaking WebSocket Test</h1>
      <p>
        Backend WS: <code>{apiUrl}</code>
      </p>
      <p>Status: <strong>{status}</strong></p>

      <div style={{ margin: "10px 0" }}>
        <button  className='dark:border dark:border-amber-50' onClick={startRecording} style={{ marginRight: 8 }}>
          Start streaming
        </button>
        <button onClick={stopRecording}>Stop</button>
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

