# 2025 Ubuntu for Python
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
sudo apt update
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
```bash
sudo apt install git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global credential.helper store
git config --global core.autocrlf input
```
In addition, if you going to work with CSV files in a git repository, make sure to add a `.gitattributes` file to the repository with the following line:
```
*.csv text eol=lf
```

### Install Python and Pip
Install Python, Pip, and the `venv` module.
```bash
sudo apt install python3 python3-pip python3-venv
```
Create a virtual environment named `pe` and activate it.
```bash
python3 -m venv pe
source pe/bin/activate
```
If for some reason you need to deactivate the environment, you can easily do it as follows.
```bash
deactivate
```

### Install Python Packages
Install essential Python ML packages:
```bash
pip install --upgrade numpy scipy pandas scikit-learn matplotlib seaborn pillow torch
```
Install OpenCV and tesseract OCR:
```bash
sudo apt-get install python3-opencv tesseract-ocr
pip install opencv-python pytesseract
```
Install popular LLM APIs:
```bash
pip install --upgrade anthropic mistralai openai
```

### Other packages
For counting tokens:
```bash
pip install --upgrade tiktoken
```
For progress bars:
```bash
pip install --upgrade tqdm
```
For GUI development (useful for making labeling apps): 
```bash
sudo apt install python3-tk
```
For finite state machines with visualization:
```bash
# Install core FSM library
pip install --upgrade transitions
# Install Graphviz runtime (for 'dot' command)
sudo apt install -y graphviz
# Install development headers (needed to build pygraphviz)
sudo apt install -y libgraphviz-dev pkg-config build-essential
# Build & install pygraphviz from source
pip install --no-binary=:all: pygraphviz
```

## Customize Shell
* Copy [`.git-prompt.sh`](.git-prompt.sh) to your home folder (`~/`).
* Append the code in [`.bashrc`](.bashrc) to your `~/.bashrc`.

## Install Cursor
Download the Cursor AppImage to the `/Downloads` directory and move it to `/opt`.
```bash
sudo mv ~/Downloads/Cursor-X.Y.Z-x86_64.AppImage /opt/cursor
sudo chmod +x /opt/cursor
```
Note: Use the same procedure to *update* cursor. The only difference is that in this case you will not only be moving the new AppImage to `/opt/cursor`, but also overwriting the old AppImage.

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
### Fixes

**Problem:** After updating Cursor you observe that it crashes while trying to load.

**First solution attempt:** Clear the configuration files and cache:
```bash
rm -rfv ~/.config/Cursor/
rm -rfv ~/.cache/cursor-updater/
```
