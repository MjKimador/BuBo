import os
import asyncio
from dotenv import load_dotenv
from typing import List, Any, Generator
from index import PDFProcessor
from openai import OpenAI

class RAGChatbot:
    def __init__(self, model_name: str = "gpt-3.5-turbo"):  # Update model name if needed
        load_dotenv()
        
        # Retrieve the API key
        self.open_api = os.getenv('OPENAI_API')
        if self.open_api is None:
            raise ValueError("OPENAI_API_KEY environment variable is not set")
        
        # Initialize OpenAI client
        self.client = OpenAI(api_key=self.open_api)
        self.pdf_processor = PDFProcessor()
        self.model_name = model_name

    def load_pdf(self, pdf_path: str, index_name: str = "pdf_index"):
        self.pdf_processor.load_and_process_pdf(pdf_path, index_name)

    def retrieve(self, query: str, num_nodes: int = 3) -> List[Any]:
        if self.pdf_processor.index is None:
            raise ValueError("No index loaded. Please load a PDF first.")
        
        retriever = self.pdf_processor.index.as_retriever(similarity_top_k=num_nodes)
        return retriever.retrieve(query)

    def generate(self, query: str, retrieved_nodes: List[Any]) -> str:
        context = "\n".join([str(node.node.get_content()) for node in retrieved_nodes])
        
        prompt = f"Context:\n{context}\n\nUser Query: {query}\n\nResponse:"

        # Create a chat completion using the OpenAI API
        chat_completion = self.client.chat.completions.create(
            messages=[
                {"role": "system", "content": """You are ArcAI, an advanced AI assistant specialized in personal finance and budgeting. Your responsibilities include:
                1. Greeting users politely only once at the start of the conversation and then stopping any further greetings.
                2. Introducing yourself once as ArcAI at the beginning of the conversation.
                3. Explaining that you're here to assist with financial planning and budgeting based on the user's spending data.
                4. Analyzing the user's previous spending data to provide personalized budget suggestions for the current month.
                5. Suggesting an optimal budget based on patterns in the user's previous expenses, categorized by necessity and frequency.
                6. Offering tips and insights to help the user manage their expenses better.
                7. Maintaining a friendly and professional tone throughout the conversation.
                8. Admitting when you don't have enough information to provide a budget or if additional data is required.
                9. Referring to previous parts of the conversation when relevant to ensure continuity in budgeting advice.

                Use the provided context and conversation history to answer the user's query and provide the best possible budget suggestions."""},
                {"role": "user", "content": prompt},
            ],
            model=self.model_name,
        )

        response = chat_completion.choices[0].message.content
        
        return response    

    def generate_stream(self, query: str, retrieved_nodes: List[Any], chunk_size: int = 100):
        """Generate and stream response in chunks."""
        response = self.generate(query, retrieved_nodes)

        for i in range(0, len(response), chunk_size):
            yield response[i:i+chunk_size]

    def query(self, user_input: str) -> Generator[str, None, None]:
        retrieved_nodes = self.retrieve(user_input)
        yield from self.generate_stream(user_input, retrieved_nodes)

# Example of how to use the chatbot
async def main():
    chatbot = RAGChatbot()
    
    # Load a PDF (provide your PDF file path)
    chatbot.load_pdf("your_document.pdf")
    
    while True:
        user_query = input("You: ")
        if user_query.lower() in ['exit', 'quit', 'bye']:
            print("Exiting the chatbot. Goodbye!")
            break
        
        responses = chatbot.query(user_query)
        for response in responses:
            print(f"ArcAI: {response}")

if __name__ == "__main__":
    asyncio.run(main())
