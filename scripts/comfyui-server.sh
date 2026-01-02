# Cài đặt và cấu hình môi trường PyTorch

sudo apt update && apt upgrade -y
source activate pytorch
pip install --upgrade pip -y
pip install --upgrade pip setuptools wheel -y
pip uninstall torch torchvision torchaudio -y
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu124 -y

# Cài đặt ComfyUI và các custom nodes
git clone https://github.com/comfyanonymous/ComfyUI.git /opt/dlami/nvme/ComfyUI
cd /opt/dlami/nvme/ComfyUI
pip3 install -r requirements.txt
cd /opt/dlami/nvme/ComfyUI/custom_nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager.git
git clone https://github.com/Fannovel16/comfyui_controlnet_aux/
git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git
git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes
cd /opt/dlami/nvme/ComfyUI/custom_nodes/ComfyUI-Manager
pip3 install -r requirements.txt
cd /opt/dlami/nvme/ComfyUI/custom_nodes/comfyui_controlnet_aux
pip3 install -r requirements.txt
cd /opt/dlami/nvme/ComfyUI/custom_nodes/ComfyUI-Custom-Scripts
pip3 install -r requirements.txt
cd /opt/dlami/nvme/ComfyUI/custom_nodes/ComfyUI_Comfyroll_CustomNodes
pip3 install -r requirements.txt

# Load mô hình chính và mô hình lora từ Amazon S3
aws s3 sync s3://sd-app-s3/models/ /opt/dlami/nvme/ComfyUI/models/checkpoints/
aws s3 sync s3://sd-app-s3/loras/ /opt/dlami/nvme/ComfyUI/models/loras/

# Tải ControlNet model và VAE model
cd /opt/dlami/nvme/ComfyUI/models/controlnet
wget https://huggingface.co/lllyasviel/control_v11p_sd15_lineart/resolve/main/diffusion_pytorch_model.fp16.safetensors -O control_v11p_sd15_lineart.safetensors
wget https://huggingface.co/lllyasviel/control_v11p_sd15_mlsd/resolve/main/diffusion_pytorch_model.fp16.safetensors -O control_v11p_sd15_mlsd.safetensors

cd /opt/dlami/nvme/ComfyUI/models/vae
wget https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors

# Tạo script khởi chạy ComfyUI
set +H
# Tạo script khởi chạy ComfyUI cho Text To Image
echo -e "#!/bin/bash\ncd /opt/dlami/nvme/ComfyUI && source activate pytorch && python3 main.py --listen 0.0.0.0 --port 8188" > /home/ubuntu/start_comfyui_text.sh
chmod +x /home/ubuntu/start_comfyui_text.sh

# Tạo script khởi chạy ComfyUI cho Sketch To Image
echo -e "#!/bin/bash\ncd /opt/dlami/nvme/ComfyUI && source activate pytorch && python3 main.py --listen 0.0.0.0 --port 8189" > /home/ubuntu/start_comfyui_sketch.sh
chmod +x /home/ubuntu/start_comfyui_sketch.sh

### Tạo dịch vụ khởi chạy ComfyUI
#Dịch vụ khởi chạy ComfyUI cho Text To Image
echo -e "[Unit]
Description=ComfyUI Service
After=network.target
[Service]
Type=simple
User=ubuntu
ExecStart=/home/ubuntu/start_comfyui_text.sh
WorkingDirectory=/opt/dlami/nvme/ComfyUI
Restart=always
[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/comfyui_text.service

#Dịch vụ khởi chạy ComfyUI cho Sketch To Image
echo -e "[Unit]
Description=ComfyUI Sketch Service
After=network.target
[Service]
Type=simple
User=ubuntu
ExecStart=/home/ubuntu/start_comfyui_sketch.sh
WorkingDirectory=/opt/dlami/nvme/ComfyUI
Restart=always
[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/comfyui_sketch.service

# Khởi tạo và bật dịch vụ ComfyUI
sudo systemctl daemon-reload
sudo systemctl enable comfyui_text.service
sudo systemctl enable comfyui_sketch.service
sudo systemctl start comfyui_text.service
sudo systemctl start comfyui_sketch.service
