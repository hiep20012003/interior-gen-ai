# Cập nhật hệ thống và cài đặt Node.js

sudo yum update -y
curl -fsSL https://rpm.nodesource.com/setup_current.x | sudo bash -
sudo yum install -y nodejs
node -v
npm -v

# Cài đặt Git và clone repo
sudo yum install git -y
git clone https://github.com/{BACKEND_REPOSITORY}
cd generate-image-app/server

# Cài đặt thư viện phụ thuộc và PM2
npm install
sudo npm install -g pm2

# Cấu hình và khởi chạy backend server với PM2
pm2 startup systemd --user $USER
pm2 start index.js --name sd-app
pm2 save

