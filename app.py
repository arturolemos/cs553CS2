import gradio as gr
from huggingface_hub import InferenceClient
import torch
from transformers import pipeline

# Inference client setup
client = InferenceClient("HuggingFaceH4/zephyr-7b-beta", token="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")
pipe = pipeline("text-generation", "microsoft/Phi-3-mini-4k-instruct", torch_dtype=torch.bfloat16, device_map="auto")

# Global flag to handle cancellation
stop_inference = False

def respond(
    message,
    history: list[tuple[str, str]],
    system_message="You are a friendly Chatbot.",
    max_tokens=512,
    temperature=0.7,
    top_p=0.95,
    use_local_model=False,
):
    global stop_inference
    stop_inference = False  # Reset cancellation flag

    # Initialize history if it's None
    if history is None:
        history = []

    if use_local_model:
        # local inference 
        messages = [{"role": "system", "content": system_message}]
        for val in history:
            if val[0]:
                messages.append({"role": "user", "content": val[0]})
            if val[1]:
                messages.append({"role": "assistant", "content": val[1]})
        messages.append({"role": "user", "content": message})

        response = ""
        for output in pipe(
            messages,
            max_new_tokens=max_tokens,
            temperature=temperature,
            do_sample=True,
            top_p=top_p,
        ):
            if stop_inference:
                response = "Inference cancelled."
                yield history + [(message, response)]
                return
            print(output)
            token = output['generated_text'][-1]['content']
            response += token
            yield history + [(message, response)]  # Yield history + new response

    else:
        # API-based inference without streaming
        messages = [{"role": "system", "content": system_message}]
        for val in history:
            if val[0]:
                messages.append({"role": "user", "content": val[0]})
            if val[1]:
                messages.append({"role": "assistant", "content": val[1]})
        messages.append({"role": "user", "content": message})

        response = client.chat_completion(
            messages,
            max_tokens=max_tokens,
            temperature=temperature,
            top_p=top_p,
        )

        yield history + [(message, response['choices'][0]['message']['content'])]

def cancel_inference():
    global stop_inference
    stop_inference = True

# Define the interface
with gr.Blocks() as demo:
    gr.Markdown("<h1 style='text-align: center;'>🌟 Fancy AI Chatbot 🌟</h1>")
    system_message = gr.Textbox(value="You are a friendly Chatbot.", label="System message", interactive=True)
    use_local_model = gr.Checkbox(label="Use Local Model", value=False)
    max_tokens = gr.Slider(minimum=1, maximum=2048, value=512, step=1, label="Max new tokens")
    temperature = gr.Slider(minimum=0.1, maximum=4.0, value=0.7, step=0.1, label="Temperature")
    top_p = gr.Slider(minimum=0.1, maximum=1.0, value=0.95, step=0.05, label="Top-p (nucleus sampling)")
    chat_history = gr.Chatbot(label="Chat")
    user_input = gr.Textbox(show_label=False, placeholder="Type your message here...")
    cancel_button = gr.Button("Cancel Inference", variant="danger")

    user_input.submit(respond, [user_input, chat_history, system_message, max_tokens, temperature, top_p, use_local_model], chat_history)
    cancel_button.click(cancel_inference)

if __name__ == "__main__":
    demo.launch(share=True)
