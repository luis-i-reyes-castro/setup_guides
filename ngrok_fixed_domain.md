# ngrok Fixed Domain Setup (Free Tier)

This guide explains how to use **ngrok's free static dev domain** so your public URL remains **constant across restarts**, which is useful for:

* WhatsApp / Meta webhooks
* chatbot experiments
* local API testing
* development servers

Without this setup, ngrok assigns a **new random URL every time it starts**.

---

# 1. Install ngrok

Download and install from:

```
https://ngrok.com/download
```

Verify installation:

```bash
ngrok version
```

Example:

```
ngrok version 3.37.1
```

---

# 2. Authenticate ngrok

Log in to the dashboard and copy your **authtoken**:

```
https://dashboard.ngrok.com/get-started/your-authtoken
```

Add it to the local config:

```bash
ngrok config add-authtoken YOUR_TOKEN
```

This creates the config file:

```
~/.config/ngrok/ngrok.yml
```

---

# 3. Find Your Free Static Domain

Open:

```
https://dashboard.ngrok.com/domains
```

You should see something like:

```
myographic-april-agrarianly.ngrok-free.dev
```

Every account receives **one free dev domain**.

Important:

* This domain **never changes**
* But **ngrok will NOT automatically use it**
* You must explicitly bind tunnels to it

---

# 4. Configure the Tunnel

Edit the ngrok config file:

```
~/.config/ngrok/ngrok.yml
```

Example configuration:

```yaml
version: "3"

agent:
  authtoken: YOUR_TOKEN

tunnels:
  chatbot:
    proto: http
    addr: 8080
    domain: myographic-april-agrarianly.ngrok-free.dev
```

Explanation:

| Field     | Meaning                      |
| --------- | ---------------------------- |
| `chatbot` | name of the tunnel           |
| `proto`   | HTTP tunnel                  |
| `addr`    | local service port           |
| `domain`  | reserved static ngrok domain |

---

# 5. Start the Tunnel

Run:

```bash
ngrok start chatbot
```

Example output:

```
Forwarding https://myographic-april-agrarianly.ngrok-free.dev -> http://localhost:8080
```

Your public URL is now:

```
https://myographic-april-agrarianly.ngrok-free.dev
```

This URL will remain **identical across restarts**.

---

# 6. Verify Tunnel

Open the local ngrok dashboard:

```
http://127.0.0.1:4040
```

This allows you to:

* inspect requests
* replay requests
* debug webhook payloads

---

# 7. Why Random URLs Appear

If you start ngrok like this:

```bash
ngrok http 8080
```

ngrok creates **ephemeral tunnels**, producing random domains such as:

```
f16a167687a5.ngrok-free.app
f1d304bb99ca.ngrok-free.app
c55dd829735a.ngrok-free.app
```

These change every run.

Using the **reserved domain** prevents this.

---

# 8. Typical Workflow

Start local server:

```bash
python app.py
```

Start ngrok:

```bash
ngrok start chatbot
```

Your webhook / API endpoint becomes:

```
https://myographic-april-agrarianly.ngrok-free.dev
```

Example webhook:

```
https://myographic-april-agrarianly.ngrok-free.dev/webhook
```

---

# 9. Notes

Free tier limits include:

* one static domain
* bandwidth limits
* connection limits

But it is sufficient for **local development and webhook testing**.

---

# Quick Reference

Start tunnel:

```bash
ngrok start chatbot
```

Config location:

```
~/.config/ngrok/ngrok.yml
```

Debug interface:

```
http://127.0.0.1:4040
```

Static domain:

```
https://myographic-april-agrarianly.ngrok-free.dev
```
