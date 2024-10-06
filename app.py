import gradio as gr
from huggingface_hub import InferenceClient
import torch
from transformers import pipeline
from pydantic import BaseModel

# Inference client setup
client = InferenceClient("HuggingFaceH4/zephyr-7b-beta")
pipe = pipeline("text-generation", "microsoft/Phi-3-mini-4k-instruct", torch_dtype=torch.bfloat16, device_map="auto")

# Global flag to handle cancellation
stop_inference = False

# Pydantic model to validate the input data
class RequestData(BaseModel):
    message: str
    history: list[tuple[str, str]]
    system_message: str = "You are a friendly Chatbot."
    max_tokens: int = 512
    temperature: float = 0.7
    top_p: float = 0.95
    use_local_model: bool = False

    class Config:
        arbitrary_types_allowed = True  # Allow arbitrary types in the model


def respond(data: RequestData):  # Accept the entire Pydantic model
    global stop_inference
    stop_inference = False  # Reset cancellation flag

    # Extract values from the Pydantic model
    message = data.message
    history = data.history or []  # Initialize history if it's None
    system_message = data.system_message
    max_tokens = data.max_tokens
    temperature = data.temperature
    top_p = data.top_p
    use_local_model = data.use_local_model

    if use_local_model:
        # Local inference logic here
        messages = [{"role": "system", "content": system_message}] + \
                   [{"role": "user", "content": val[0]} for val in history if val[0]] + \
                   [{"role": "assistant", "content": val[1]} for val in history if val[1]] + \
                   [{"role": "user", "content": message}]

        response = ""
        for output in pipe(
            messages,
            max_new_tokens=max_tokens,
            temperature=temperature,
            do_sample=True,
            top_p=top_p,
        ):
            if stop_inference:
                yield history + [(message, "Inference cancelled.")]
                return
            
            token = output['generated_text'][-1]['content']
            response += token
            yield history + [(message, response)]  # Yield history + new response

    else:
        # API-based inference logic here
        messages = [{"role": "system", "content": system_message}] + \
                   [{"role": "user", "content": val[0]} for val in history if val[0]] + \
                   [{"role": "assistant", "content": val[1]} for val in history if val[1]] + \
                   [{"role": "user", "content": message}]

        response = ""
        for message_chunk in client.chat_completion(
            messages,
            max_tokens=max_tokens,
            stream=True,
            temperature=temperature,
            top_p=top_p,
        ):
            if stop_inference:
                yield history + [(message, "Inference cancelled.")]
                return
            
            token = message_chunk.choices[0].delta.content
            response += token
            yield history + [(message, response)]  # Yield history + new response


def cancel_inference():
    global stop_inference
    stop_inference = True


# Define the Gradio interface as before
with gr.Blocks() as demo:
    gr.Markdown("<h1 style='text-align: center;'>🌟 Fancy AI Chatbot 🌟</h1>")
    gr.Markdown("Interact with the AI chatbot using customizable settings below.")

    with gr.Row():
        system_message = gr.Textbox(value="You are a friendly Chatbot.", label="System message", interactive=True)
        use_local_model = gr.Checkbox(label="Use Local Model", value=False)

    with gr.Row():
        max_tokens = gr.Slider(minimum=1, maximum=2048, value=512, step=1, label="Max new tokens")
        temperature = gr.Slider(minimum=0.1, maximum=4.0, value=0.7, step=0.1, label="Temperature")
        top_p = gr.Slider(minimum=0.1, maximum=1.0, value=0.95, step=0.05, label="Top-p (nucleus sampling)")

    chat_history = gr.Chatbot(label="Chat")
    user_input = gr.Textbox(show_label=False, placeholder="Type your message here...")
    cancel_button = gr.Button("Cancel Inference", variant="danger")

    # Adjust the submit function to pass the entire data model
    user_input.submit(respond, [gr.State(value={'message': user_input, 'history': chat_history, 'system_message': system_message, 'max_tokens': max_tokens, 'temperature': temperature, 'top_p': top_p, 'use_local_model': use_local_model})], chat_history)

    cancel_button.click(cancel_inference)

if __name__ == "__main__":
    demo.launch()
