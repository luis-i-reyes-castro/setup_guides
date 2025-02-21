# 2025 Ubuntu Python ML Dev Setup Guide
This guide will help you set up your Ubuntu 24.04 system. It assumes you are sharing the disk with a Windows or mac operating system, hence the inclusion of the `grub-customizer`. It installs Google Chrome, GIT, a Python virtual environment, some Python ML packages, and Cursor. It also includes steps to automate the activation of your Python environment.

## Update and Upgrade System
Start by updating and upgrading your system to ensure all packages are up to date.
```bash
sudo apt update
sudo apt upgrade
```
## Install Essential Tools

### Install Grub Customizer
Grub Customizer allows you to customize the GRUB bootloader in case Ubuntu is sharing the disk with a Windows OS or macOS.
```bash
sudo add-apt-repository ppa:danielrichter2007/grub-customizer
sudo apt install grub-customizer
sudo grub-customizer
```
### Install Google Chrome
Add the Google Chrome repository and install the browser.
```bash
wget -qO - https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome-keyring.gpg
echo 'deb [signed-by=/usr/share/keyrings/google-chrome-keyring.gpg] https://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt update
sudo apt install google-chrome-stable
```
### Install GIT
Git is essential for version control.
```bash
sudo apt install git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global credential.helper store
```
## Set Up Python Environment

### Install Python and Pip
Install Python, Pip, and the `venv` module.
```bash
sudo apt install python3 python3-pip python3-venv
```

### Create and Activate a Python Virtual Environment
Create a virtual environment named `pe` and activate it.
```bash
python3 -m venv pe
source pe/bin/activate
```
### Install Python Packages
Install essential Python ML packages.
```bash
pip install --upgrade numpy scipy pandas scikit-learn matplotlib seaborn pillow torch openai
```
Install OpenCV and tesseract OCR.
```bash
sudo apt-get install python3-opencv tesseract-ocr
pip install opencv-python pytesseract
```
Install other useful packages.
```bash
pip install tiktoken tqdm
```
Install tkinter for GUI development (useful for making labeling UIs).
```bash
sudo apt install python3-tk
```

### Deactivate the Environment
When you're done, deactivate the environment.
```bash
deactivate
```

### Automate Python Environment Activation
To automatically activate the `pe` environment when opening a terminal, add the activation command to your `.bashrc` file.
```bash
echo 'source ~/pe/bin/activate' >> ~/.bashrc
```
Reload the .bashrc file to apply the changes.
```bash
source ~/.bashrc
```

## Install Cursor
Cursor is a AI IDE that can be installed as an AppImage. It provides a significant productivity boost over non-AI IDEs.

### Download and Install Cursor
Download the Cursor AppImage to the `/Downloads` directory and move it to /opt.
```bash
sudo mv ~/Downloads/cursor-0.45.11x86_64.AppImage /opt/cursor
sudo chmod +x /opt/cursor
```

### Download a Cursor Icon
Download a cursor icon as `cursor-icon.png` to the `/Downloads` directory, create a directory for the icon (to avoid overwriting the app), and move it.
```bash
sudo mkdir -p /opt/cursor-icons
sudo mv ~/Downloads/cursor-icon.png /opt/cursor-icons/cursor-icon.png
```

### Create a Desktop Entry
Create a `.desktop` file to launch Cursor from the applications menu.
```bash
gedit ~/.local/share/applications/cursor.desktop
```
Add the following content to the file:
```ini
[Desktop Entry]
Name=Cursor
Exec=/opt/cursor --no-sandbox
Icon=/opt/cursor-icons/cursor-icon.png
Type=Application
Categories=Development;
```
Save the file and make it executable.
```bash
chmod +x ~/.local/share/applications/cursor.desktop
update-desktop-database ~/.local/share/applications
```
