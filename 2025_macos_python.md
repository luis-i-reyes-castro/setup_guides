# 2025 MacOS Python ML Dev Setup Guide
This guide will help you set up your MacOS system. It installs Brew, GIT, a Python virtual environment, and some Python ML packages.

## Install Essential Tools

### Install Brew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew upgrade
brew cleanup
```

### Install GIT
Git is essential for version control.
```bash
brew install git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global credential.helper store
git config --global core.autocrlf input
```
In addition, if you going to work with CSV files in a git repository, make sure to add a `.gitattributes` file to the repository with the following line:
```
*.csv text eol=lf
```

## Set Up Python Environment

### Install Python and Pip
Install Python, Pip, and the `venv` module.
```bash
brew install python3
```
Verify installation.
```bash
python3 --version
pip3 --version
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
pip install --upgrade numpy scipy pandas scikit-learn matplotlib seaborn pillow torch
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
Install popular LLM APIs.
```bash
pip openai mistralai deepseek langchain langchain-community langchain-openai
```

### Automate Python Environment Activation
To automatically activate the `pe` environment when opening a terminal, add the activation command to your `.bashrc` file.
```bash
echo 'source ~/pe/bin/activate' >> ~/.zshrc
```
Reload the .bashrc file to apply the changes.
```bash
source ~/.bashrc
```
Alternatively, you may simply close and re-open the terminal.

### Deactivate the Environment
If for some reason you need to deactivate the environment, you can easily do it as follows.
```bash
deactivate
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
