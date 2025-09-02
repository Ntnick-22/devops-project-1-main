#!/bin/bash
cd /home/ubuntu
sudo apt update -y
sudo apt install -y python3 python3-pip python3-venv

# Clone the correct repository name
git clone https://github.com/Ntnick-22/python-mysql-db-proj-1-main.git
cd python-mysql-db-proj-1-main

# Create virtual environment to avoid PEP 668 issues
python3 -m venv venv
source venv/bin/activate

# Install dependencies (create requirements.txt if missing)
pip install flask pymysql

echo 'Waiting for 30 seconds before running the app.py'
sleep 30

# Run the app in the background
nohup python3 app.py > /var/log/flask-app.log 2>&1 &