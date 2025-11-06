import os
from flask import Flask, request, jsonify, render_template_string
import numpy as np
import tensorflow as tf
from tensorflow.keras.preprocessing.image import load_img, img_to_array
from io import BytesIO

# --- Configuration (Must match your training script) ---
# NOTE: The file 'leaf_health_model.tflite' must be placed in the same directory as this app.py file.
MODEL_PATH = '../doubleLabelLeafDetector.tflite'
IMAGE_SIZE = (256, 256)

# These lists must exactly match the order inferred during model training
LEAF_TYPES = ['Camphor', 'HariTaki', 'Neem', 'Sojina']
HEALTH_LABELS = ['Bacterial Spot', 'Healthy Leaf', 'Powdery Mildew', 'Shot Hole', 'Yellow Leaf', 'Spot Leaf'] 
NUM_LEAF_CLASSES = len(LEAF_TYPES)
NUM_HEALTH_CLASSES = len(HEALTH_LABELS)

# --- TFLite Model Loading (Global for performance) ---
interpreter = None
input_details = None
output_details = None

def load_tflite_model():
    """Loads the TFLite model interpreter once."""
    global interpreter, input_details, output_details
    try:
        if not os.path.exists(MODEL_PATH):
            print(f"ERROR: Model file not found at {MODEL_PATH}")
            return False

        # Load the TFLite model and allocate tensors
        interpreter = tf.lite.Interpreter(model_path=MODEL_PATH)
        interpreter.allocate_tensors()

        # Get input and output tensor details
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()

        print("TFLite Model loaded successfully into memory.")
        return True
    except Exception as e:
        print(f"Error loading TFLite model: {e}")
        return False

# Initialize Flask App
app = Flask(__name__)

# Load the model immediately when the app starts. This is where the 58MB will be loaded into RAM.
model_loaded = load_tflite_model()

# --- Routes ---

@app.route('/')
def home():
    """Simple health check and info route."""
    status = "Ready" if model_loaded else "Error: Model not loaded"
    
    html_content = f"""
    <div style="font-family: Arial, sans-serif; padding: 20px; text-align: center; background-color: #f4f4f9; border-radius: 8px;">
        <h1 style="color: #4CAF50;">Leaf Health Prediction API</h1>
        <p><strong>Status:</strong> <span style="color: {'green' if model_loaded else 'red'};">{status}</span></p>
        <p>This backend is for testing deployment feasibility on the Render Free Tier (512MB RAM).</p>
        <p>To test prediction, send a <strong>POST</strong> request to the <code>/predict</code> endpoint with an image file.</p>
        <p><strong>Input Shape Expected:</strong> {IMAGE_SIZE}x3</p>
        <p><strong>Model File Size:</strong> 58 MB (To be loaded into 512MB container RAM)</p>
    </div>
    """
    return render_template_string(html_content)


@app.route('/predict', methods=['POST'])
def predict_image():
    """Handles image upload and runs TFLite inference."""
    if not model_loaded:
        return jsonify({"error": "Model failed to load. Check server logs."}), 500

    if 'file' not in request.files:
        return jsonify({"error": "No file part in the request"}), 400

    file = request.files['file']

    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    try:
        # 1. Load and process the image
        image_bytes = BytesIO(file.read())
        img = load_img(image_bytes, target_size=IMAGE_SIZE)
        img_array = img_to_array(img)
        
        # Normalize and expand dimensions (Add batch dimension)
        # Note: TFLite models often expect float32 input in the range [0, 1]
        input_data = np.expand_dims(img_array, axis=0).astype(np.float32) / 255.0

        # 2. TFLite Inference
        interpreter.set_tensor(input_details[0]['index'], input_data)
        interpreter.invoke()

        # 3. Get outputs (Assumes two outputs: leaf_output and health_output)
        # The output order in output_details[0] and output_details[1] corresponds
        # to the order defined when the model was compiled/converted. 
        # We assume output_details[0] is LEAF and output_details[1] is HEALTH.
        # If order is wrong, swap the indices.
        
        leaf_output = interpreter.get_tensor(output_details[0]['index'])
        health_output = interpreter.get_tensor(output_details[1]['index'])

        # 4. Post-processing
        leaf_idx = np.argmax(leaf_output[0])
        health_idx = np.argmax(health_output[0])

        pred_leaf_name = LEAF_TYPES[leaf_idx]
        pred_health_name = HEALTH_LABELS[health_idx]
        
        leaf_confidence = float(leaf_output[0][leaf_idx])
        health_confidence = float(health_output[0][health_idx])

        # 5. Return results
        return jsonify({
            "status": "success",
            "prediction": {
                "leaf_type": pred_leaf_name,
                "health_label": pred_health_name,
            },
            "confidence": {
                "leaf_type": f"{leaf_confidence:.4f}",
                "health_label": f"{health_confidence:.4f}"
            }
        })

    except Exception as e:
        # Log the full traceback in a real scenario
        print(f"Prediction Error: {e}") 
        return jsonify({"error": f"An error occurred during prediction: {str(e)}"}), 500

if __name__ == '__main__':
    # Using Gunicorn in production is standard, but for local testing:
    # Use 'gunicorn app:app' in deployment
    app.run(debug=True, host='0.0.0.0', port=os.environ.get('PORT', 5000))