import os
from flask import Flask, request, jsonify, render_template_string
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

client = OpenAI(
    api_key=os.getenv("XAI_API_KEY"),
    base_url="https://api.x.ai/v1"
)

history = [
    {
        "role": "system",
        "content": "You are Grok, a helpful AI chatbot."
    }
]

HTML = """
<!DOCTYPE html>
<html>
<head>
<title>Grok Chatbot</title>
<style>
body { font-family: Arial; max-width:700px; margin:auto; }
#chat { height:400px; overflow:auto; border:1px solid #ccc; padding:10px; }
input { width:80%; padding:10px; }
button { padding:10px; }
</style>
</head>
<body>

<h1>🤖 Grok Chatbot</h1>

<div id="chat"></div>

<input id="msg" placeholder="Say something...">
<button onclick="send()">Send</button>

<script>
async function send(){
    let box=document.getElementById("msg");
    let chat=document.getElementById("chat");

    chat.innerHTML += "<p><b>You:</b> "+box.value+"</p>";

    let res=await fetch("/chat",{
        method:"POST",
        headers:{"Content-Type":"application/json"},
        body:JSON.stringify({message:box.value})
    });

    let data=await res.json();

    chat.innerHTML += "<p><b>Grok:</b> "+data.reply+"</p>";
    box.value="";
}
</script>

</body>
</html>
"""

@app.route("/")
def home():
    return render_template_string(HTML)


@app.route("/chat", methods=["POST"])
def chat():
    user=request.json["message"]

    history.append({
        "role":"user",
        "content":user
    })

    response=client.chat.completions.create(
        model="grok-4",
        messages=history
    )

    reply=response.choices[0].message.content

    history.append({
        "role":"assistant",
        "content":reply
    })

    return jsonify({"reply":reply})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT",5000)))
