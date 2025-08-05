from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import tempfile
import os
import subprocess
import base64
from pathlib import Path
import uuid

app = FastAPI()

class ManimRequest(BaseModel):
    code: str
    scene_name: str = "Scene"

@app.post("/generate")
async def generate_animation(request: ManimRequest):
    try:
        # Create unique identifier for this animation
        animation_id = str(uuid.uuid4())
        
        # Create temporary directory for this animation
        temp_dir = f"/tmp/manim_{animation_id}"
        os.makedirs(temp_dir, exist_ok=True)
        
        # Write the Manim code to a temporary file
        code_file = f"{temp_dir}/scene.py"
        with open(code_file, "w") as f:
            f.write(request.code)
        
        # Run Manim to generate the animation
        output_dir = f"{temp_dir}/media"
        cmd = [
            "manim",
            "-pql",  # Preview quality, low resolution for faster generation
            "--media_dir", output_dir,
            code_file,
            request.scene_name
        ]
        
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=60  # 60 second timeout
        )
        
        if result.returncode != 0:
            raise HTTPException(
                status_code=400, 
                detail=f"Manim execution failed: {result.stderr}"
            )
        
        # Find the generated video file
        videos_dir = Path(output_dir) / "videos" / "scene" / "480p15"
        video_files = list(videos_dir.glob("*.mp4"))
        
        if not video_files:
            raise HTTPException(
                status_code=500,
                detail="No video file was generated"
            )
        
        video_file = video_files[0]
        
        # Read and encode the video file as base64
        with open(video_file, "rb") as f:
            video_data = base64.b64encode(f.read()).decode()
        
        # Clean up temporary files
        subprocess.run(["rm", "-rf", temp_dir])
        
        return {
            "success": True,
            "video_base64": video_data,
            "filename": f"{animation_id}.mp4"
        }
        
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=408, detail="Animation generation timed out")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)