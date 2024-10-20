import os
from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from updated import RAGChatbot

load_dotenv()

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

chatbot = RAGChatbot()

@app.on_event("startup")
def startup_event():
    chatbot.load_pdf("expense.txt", "my_pdf_index")

@app.websocket("/ws/chat")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()

    # Ask the user how much they received for the current month
    await websocket.send_json({
        "text": "Please enter the amount you received for the current month:",
        "finished": False
    })
    
    try:
        income = await websocket.receive_text()

        # Confirm receipt of income
        await websocket.send_json({
            "text": f"Thank you! You entered: {income}. How can I assist you with your budget?",
            "finished": False
        })

        while True:
            try:
                message = await websocket.receive_text()

                # Pass the user's income and query to the chatbot
                full_message = f"User's monthly income: {income}. User query: {message}"
                
                for chunk in chatbot.query(full_message):
                    await websocket.send_json({
                        "text": chunk,
                        "finished": False
                    })
                
                await websocket.send_json({
                    "text": "",
                    "finished": True
                })
            except Exception as e:
                print(f"Error: {e}")
                await websocket.close()
                break
    except Exception as e:
        print(f"Error: {e}")
        await websocket.close()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="localhost", port=8000)
