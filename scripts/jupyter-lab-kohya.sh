# Install a separate conda installation via Miniconda
WORKING_DIR=/home/ec2-user/SageMaker
mkdir -p "$WORKING_DIR"
wget https://repo.anaconda.com/miniconda/Miniconda3-py310_23.5.2-0-Linux-x86_64.sh -O "$WORKING_DIR/miniconda.sh"
bash "$WORKING_DIR/miniconda.sh" -b -u -p "$WORKING_DIR/miniconda"
rm -rf "$WORKING_DIR/miniconda.sh"

# Create a custom conda environment
source "$WORKING_DIR/miniconda/bin/activate"
KERNEL_NAME="kohya"
PYTHON="3.10.12"  # Updated to Python 3.10.12
conda create --yes --name "$KERNEL_NAME" python="$PYTHON"
conda activate "$KERNEL_NAME"
pip install --quiet ipykernel

# Clone and set up kohya_ss project
cd SageMaker
git clone https://github.com/bmaltais/kohya_ss
cd kohya_ss
python3 -m venv venv
source venv/bin/activate
./setup.sh -n
source /home/ec2-user/SageMaker/miniconda/bin/activate
conda activate kohya
bash /home/ec2-user/SageMaker/kohya_ss/gui.sh --share
