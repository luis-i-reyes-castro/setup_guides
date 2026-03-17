# Mailgun Setup for Transactional Email

This guide configures **Mailgun** to send transactional emails from a DigitalOcean server when outbound SMTP is blocked.

Architecture used:

```
App (DigitalOcean droplet)
        ↓ HTTPS API
Mailgun
        ↓
Recipient email
```

SMTP is **not used**.

---

# 1. Create Mailgun Account

Create an account at:

```
https://www.mailgun.com
```

Choose region: **US** or **EU**

---

# 2. Add Sending Domain

Add a dedicated subdomain for transactional email.

Example:

```
mail.sofia-systems.com
```

Using a subdomain keeps:

* human email separate
* sender reputation isolated

Example sender addresses:

```
facturacion@mail.sofia-systems.com
no-reply@mail.sofia-systems.com
```

---

# 3. Configure DNS in Namecheap

Open:

```
Domain → Advanced DNS
```

## Host Records

Add:

### CNAME (tracking)

```
Type:  CNAME
Host:  email.mail
Value: mailgun.org.
TTL:   Automatic
```

### TXT (DKIM)

```
Type:  TXT
Host:  pdk1._domainkey.mail
Value: pdk1._domainkey...mgsend.org.
TTL:   Automatic
```

```
Type:  TXT
Host:  pdk2._domainkey.mail
Value: pdk2._domainkey...mgsend.org.
TTL:   Automatic
```

### TXT (SPF)

```
Type:  TXT
Host:  mail
Value: v=spf1 include:mailgun.org ~all
TTL:   Automatic
```

---

## Mail Settings → Custom MX

Add:

### MX #1

```
Type:     MX
Host:     mail
Value:    mxa.mailgun.org
Priority: 10
TTL:      Automatic
```

### MX #2

```
Type:     MX
Host:     mail
Value:    mxb.mailgun.org
Priority: 10
TTL:      Automatic
```

Important:

```
Host must be "mail"
NOT mail.sofia-systems.com
```

---

# 4. Wait for DNS Propagation

### Check host records:

Command:
```bash
dig [a|cname|txt] {$HOST}.sofia-systems.com +short
```

**NOTE:** For the A Record with host `@` just run `dig a sofia-systems.com +short`.

E.g.:
```bash
dig a sofia-systems.com +short
dig cname email.mail.sofia-systems.com +short
dig txt mail.sofia-systems.com +short
```

Expected output: `Value`

### Check MX:

Command:
```bash
dig mx mail.sofia-systems.com +short
```

Expected output:
```
10 mxa.mailgun.org.
10 mxb.mailgun.org.
```

---

# 5. Verify Domain in Mailgun

In Mailgun dashboard:

```
Domain Settings → DNS Records
```

Click:

```
Check Status
```

All records should turn **green**:

```
Sending
Receiving
Tracking
```

---

# 6. Get API Key

Open:

```
Mailgun → Sending → API Keys
```

Copy **Private API key**.

Example:

```
key-xxxxxxxxxxxxxxxx
```

---

# 7. Store API Key on Server

Example:

```bash
export MAILGUN_API_KEY="key-xxxxxxxxxxxx"
```

Or add to:

```
/etc/environment
```

---

# 8. Send Email via HTTPS API (Python)

Example:

```python
import os
import requests

MAILGUN_API_KEY = os.getenv("MAILGUN_API_KEY")
DOMAIN = "mail.sofia-systems.com"

response = requests.post(
    f"https://api.eu.mailgun.net/v3/{DOMAIN}/messages",
    auth=("api", MAILGUN_API_KEY),
    data={
        "from": f"Sofia Systems <no-reply@{DOMAIN}>",
        "to": ["user@example.com"],
        "subject": "Test email",
        "text": "Mailgun setup successful"
    }
)

print(response.status_code)
print(response.text)
```

Expected response:

```
200
Queued. Thank you.
```

---

# 9. Optional (Recommended): Add DMARC

DNS record:

```
Type:  TXT
Host:  _dmarc
Value: v=DMARC1; p=none; rua=mailto:admin@sofia-systems.com
```

This improves deliverability.

---

# Result

Email sending works from DigitalOcean despite SMTP blocks because delivery uses:

```
HTTPS → Mailgun API
```

No SMTP ports required.
