# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.8.4-base

# build-time tokens for gated downloads — never baked into final image.
# pass via: docker build --build-arg HF_TOKEN=$HF_TOKEN ...
ARG HF_TOKEN=""
ARG CIVITAI_API_KEY=""

# install custom nodes into comfyui
RUN git clone https://github.com/chflame163/ComfyUI_LayerStyle /comfyui/custom_nodes/ComfyUI_LayerStyle && cd /comfyui/custom_nodes/ComfyUI_LayerStyle && (git checkout d94bef1ee5ed3656f5ff1bb2830a4ffd94f40935 2>/dev/null || (git fetch origin d94bef1ee5ed3656f5ff1bb2830a4ffd94f40935 --depth=1 && git checkout d94bef1ee5ed3656f5ff1bb2830a4ffd94f40935) || echo "WARN: commit d94bef1ee5ed3656f5ff1bb2830a4ffd94f40935 unreachable in https://github.com/chflame163/ComfyUI_LayerStyle, falling back to default branch HEAD")
RUN git clone https://github.com/kijai/ComfyUI-KJNodes /comfyui/custom_nodes/ComfyUI-KJNodes && cd /comfyui/custom_nodes/ComfyUI-KJNodes && (git checkout 35a5a1ffea9061e698d1a742ac071b287b843dd3 2>/dev/null || (git fetch origin 35a5a1ffea9061e698d1a742ac071b287b843dd3 --depth=1 && git checkout 35a5a1ffea9061e698d1a742ac071b287b843dd3) || echo "WARN: commit 35a5a1ffea9061e698d1a742ac071b287b843dd3 unreachable in https://github.com/kijai/ComfyUI-KJNodes, falling back to default branch HEAD")
RUN git clone https://github.com/yolain/ComfyUI-Easy-Use /comfyui/custom_nodes/ComfyUI-Easy-Use && cd /comfyui/custom_nodes/ComfyUI-Easy-Use && (git checkout 81c510c06e18dffd4f43518644fc35964c9168ca 2>/dev/null || (git fetch origin 81c510c06e18dffd4f43518644fc35964c9168ca --depth=1 && git checkout 81c510c06e18dffd4f43518644fc35964c9168ca) || echo "WARN: commit 81c510c06e18dffd4f43518644fc35964c9168ca unreachable in https://github.com/yolain/ComfyUI-Easy-Use, falling back to default branch HEAD")
RUN git clone https://github.com/rgthree/rgthree-comfy /comfyui/custom_nodes/rgthree-comfy && cd /comfyui/custom_nodes/rgthree-comfy && (git checkout 8ff50e4521881eca1fe26aec9615fc9362474931 2>/dev/null || (git fetch origin 8ff50e4521881eca1fe26aec9615fc9362474931 --depth=1 && git checkout 8ff50e4521881eca1fe26aec9615fc9362474931) || echo "WARN: commit 8ff50e4521881eca1fe26aec9615fc9362474931 unreachable in https://github.com/rgthree/rgthree-comfy, falling back to default branch HEAD")

# download models into comfyui
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/Comfy-Org/flux2-klein-9B/resolve/main/split_files/text_encoders/qwen_3_8b_fp8mixed.safetensors' --relative-path models/text_encoders --filename 'qwen_3_8b_fp8mixed.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors' --relative-path models/vae --filename 'flux2-vae.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="60 300 900 1800 3600" && for i in 1 2 3 4 5; do CIVITAI_API_KEY=$CIVITAI_API_KEY comfy model download --url 'https://civitai.com/api/download/models/2775495' --relative-path models/loras --filename 'flux-2-klein/Dirty_Public_Restroom.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/dhruv565699/darkBeastMar0326Latest/resolve/main/darkBeastMar0326Latest_dbkleinv2BFS.safetensors' --relative-path models/diffusion_models --filename 'flux-2-klein/F2K-9b-darkBeastMar0326Latest_dbkleinv2BFS.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/

# user-provided inputs override the auto-generated placeholders above.
RUN wget --progress=dot:giga -O '/comfyui/input/mmexport1690194117589.jpg' "https://cool-anteater-319.convex.cloud/api/storage/3bf97a15-627c-4a66-b70a-5d14f4bfe784"
