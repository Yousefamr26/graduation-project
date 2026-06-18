import gradio as gr
from huggingface_hub import InferenceClient
from pypdf import PdfReader
import tempfile
import os
import json


HF_TOKEN = os.getenv("HF_TOKEN")
client = InferenceClient("meta-llama/Meta-Llama-3-70B-Instruct", token=HF_TOKEN)

def extract_text(file_obj, raw_text):
    if file_obj is not None:
        try:
            reader = PdfReader(file_obj.name)
            extracted = ""
            for page in reader.pages:
                content = page.extract_text()
                if content:
                    extracted += content + "\n"
            return extracted
        except Exception as e:
            return f"Error reading PDF: {str(e)}"
    return raw_text

def generate_quiz(file_obj, raw_text, quiz_type, num_questions):
    context = extract_text(file_obj, raw_text)
    
    if not context or len(context.strip()) < 50:
        return "Please provide sufficient text or upload a PDF file.", None

    prompt = f"""
    Context: {context[:10000]}
    ---
    Task: Generate {num_questions} {quiz_type} questions based on the context.
    Return ONLY a valid JSON array of objects. Do not include any intro or outro text.
    
    JSON Structure Example for MCQ:
    [
      {{
        "question": "Question text here",
        "options": ["A) Choice1", "B) Choice2", "C) Choice3", "D) Choice4"],
        "answer": "A"
      }}
    ]
    
    JSON Structure Example for True/False:
    [
      {{
        "question": "Statement here",
        "answer": "True/False"
      }}
    ]
    
    Language: Match the context language.
    """
    
    try:
        response = client.chat_completion(
            messages=[{"role": "user", "content": prompt}],
            max_tokens=4000,
            stream=False,
        )
        
        full_response = response.choices[0].message.content
        
        if full_response.strip():
            with tempfile.NamedTemporaryFile(delete=False, suffix=".json", mode="w", encoding="utf-8") as temp_file:
                temp_file.write(full_response)
                file_path = temp_file.name
            
            return full_response, file_path
        
        return "Empty response from model.", None
        
    except Exception as e:
        return f"Error: {str(e)}", None


with gr.Blocks(title="Quiz Engine model") as demo:
    gr.Markdown("# Quiz Engine model")
    gr.Markdown("Question and Answer Generator: True/False or MCQ")
    
    with gr.Row():
        with gr.Column():
            file_input = gr.File(label="Upload PDF", file_types=[".pdf"])
            text_input = gr.Textbox(label="Input Context", lines=10, placeholder="Paste your text here...")
            q_type = gr.Dropdown(["MCQ", "True/False"], label="Question Type", value="MCQ")
            q_count = gr.Slider(1, 20, 5, label="Question Count")
            btn = gr.Button("Generate JSON", variant="primary")
            
        with gr.Column():
            output_json = gr.Code(label="JSON Response", language="json")
            download_link = gr.File(label="Download JSON File")

    btn.click(
        fn=generate_quiz, 
        inputs=[file_input, text_input, q_type, q_count], 
        outputs=[output_json, download_link],
        api_name="predict"
    )

if __name__ == "__main__":
   
    demo.launch(theme=gr.themes.Soft())