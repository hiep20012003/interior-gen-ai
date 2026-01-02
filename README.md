# AWS Stable Diffusion System
The automated interior design support system utilizes Stable Diffusion 1.5 and ComfyUI, deployed on AWS infrastructure. The application allows for the creation of high-quality images of living spaces from descriptive text or hand-drawn sketches, helping designers quickly develop visually appealing and professional concepts.

## 1. System Architecture
The system is deployed on an **AWS VPC** with a division between a **Public Subnet** (containing the Backend and Gateway) and a **Private Subnet** (containing the ML Server and SageMaker) to ensure security.

![alt text](/assets/images/aws-architecture.png)

## 2. Infrastructure Automation (AWS CloudFormation)
Use the YAML template file to initialize all necessary resources.

![alt text](/assets/images/cloud-formation.png)

1. Access **AWS CloudFormation**.

2. Upload the `aws-cloud-formation.yaml` file.

3. Configure the parameters:

* **VPC**: CIDR 172.16.0.0/16.

* **EC2 Instances**: `t2.medium` for the Backend and `g5.xlarge` for the ML Server.

* **S3 Bucket**: Create a `sd-app-s3` bucket to store the model and data.

4. Click **Submit** and wait for the `CREATE_COMPLETE` status.

## 3. Fine-tune the LoRA Model (AWS SageMaker)
Train the model to recognize specific interior design styles.

1. Open the **SageMaker Notebook Instance** (`FineTuneNotebookInstance`).

2. Open the Terminal and deploy the **Kohya_ss** tool (see `jupyter-lab-kohya.sh`)

3. Prepare the data:

* Load images (512x512) into the `dataset/images` directory.

* Use **BLIP Captioning** to automatically assign descriptive labels to the images.

4. Train and synchronize the results to S3 using the command:

`aws s3 sync ./ s3://sd-app-s3/loras/`.

## 4. Step 3: Deploy ML Server (ComfyUI)
Set up the image generation workflow orchestration tool on EC2 G5 (`comfyui-server.sh`).

1. Connect to the **MLServer** via SSH.

2. Install the **PyTorch** and CUDA environments.

3. Install **ComfyUI** and the custom nodes (Manager, ControlNet, Comfyroll).

4. Download the model from S3 to the server:

* Main model: `interiordesignsuperm_v2.safetensors`.

* LoRA models: Indochine, Minimalist styles, etc.

5. Initialize the system service (`systemd`) to keep ComfyUI running on ports 8188 (Text) and 8189 (Sketch).

## 5. Step 4: Deploy Backend Server
The server coordinates between the user interface and AI (`backend.sh`).

1. Connect to the **BackendServer** via SSH.

2. Install **Node.js** and clone the source code from GitHub.

3. Configure the `.env` file: set `COMFY_UI_ADDRESS` to point to the ML Server's private IP.

4. Use **PM2** to manage the application process:

`pm2 start index.js --name sd-app`.

## 6. Step 5: Frontend Deployment (AWS Amplify)
Provide a Web interface for end users.

1. Create a **GitHub Fine-grained token** with repository access.

2. Connect the repository to **AWS Amplify**.

3. Amplify will automatically perform the Build and Deploy process from the `main` branch.

4. Access the application via the Domain provided by Amplify.
