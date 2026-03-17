# NameCheap Advanced DNS Setup Guide

Example situation:
  * Rented VPS/droplet with IP address `XYZ.ABC.IJK.LM`
  * Bought domain `sofia-systems.com`
  * Ran `certbot` in the droplet to generate an [SSL certificate](ssl_certificate.md) for the domain.

We would like to setup:
  * Domains:
    * Main: `https://sofia-systems.com` and `https://www.sofia-systems.com`
    * WhatsApp Backend: `https://wa.sofia-systems.com`
  * [Mailgun API](mailgun.md) for sending emails
  * Google Workspace for inbox

---

## Main Domain and WhatsApp Backend

### Host Records

| Type | Host | Value | TTL |
|------|------|-------|-----|
| A Record | `@`   | `XYZ.ABC.IJK.LM` | Automatic |
| A Record | `wa`  | `XYZ.ABC.IJK.LM` | Automatic |
| A Record | `www` | `XYZ.ABC.IJK.LM` | Automatic |

---

## Mailgun API

### Host Records

Choose the automatic setup option and the first four records in the table below will appear automatically. The DMARC record (last row) must be added manually.

| Type | Host | Value | TTL |
|------|------|-------|-----|
| CNAME Record | email.mail         | mailgun.org.                    | 5 min     |
| CNAME Record | pdk1._domainkey... | pdk1._domainkey...              | 5 min     |
| CNAME Record | pdk2._domainkey... | pdk2._domainkey...              | 5 min     |
| TXT Record   | mail               | v=spf1 include:mailgun.org ~all | 5 min     |

We suggest also adding the Mailgun-generated DMARC record:

| Type | Host | Value | TTL |
|------|------|-------|-----|
| TXT Record | _dmarc.mail | v=DMARC1; p=none; pct=100; fo=1; ri=3600; rua=mail... | 5 min |

### Mail Settings ➡️ Custom MX

| Type      | Host | Value             | Priority | TTL       |
|-----------|------|-------------------|----------|-----------|
| MX Record | mail | mxa.mailgun.org.  | 10       | Automatic |
| MX Record | mail | mxb.mailgun.org.  | 10       | Automatic |

---

## Google Workspace

### Host Records

| Type | Host | Value | TTL |
|------|------|-------|-----|
| TXT Record | @                 | google-site-verification=... | Automatic |
| TXT Record | google._domainkey | v=DKIM1;k=rsa;p=...          | Automatic |

### Mail Settings ➡️ Custom MX

| Type | Host | Value | TTL |
|------|------|-------|-----|
| MX Record | @ | SMTP.GOOGLE.COM. | 1 | Automatic |


---

## Summary

### Host Records

| Use | Type | Host | Value |
|-----|------|------|-------|
| Main Domain and WhatsApp Backend | A Record | `@`   | `XYZ.ABC.IJK.LM` |
| Main Domain and WhatsApp Backend | A Record | `wa`  | `XYZ.ABC.IJK.LM` |
| Main Domain and WhatsApp Backend | A Record | `www` | `XYZ.ABC.IJK.LM` |
| Mailgun | CNAME Record | email.mail         | mailgun.org.                    |
| Mailgun | CNAME Record | pdk1._domainike... | pdk1._domainkey...              |
| Mailgun | CNAME Record | pdk2._domainike... | pdk2._domainkey...              |
| Google Workspace | TXT Record | @                 | google-site-verification=... |
| Google Workspace | TXT Record | google._domainkey | v=DKIM1;k=rsa;p=...          |
| Mailgun | TXT Record   | mail               | v=spf1 include:mailgun.org ~all |
| Mailgun | TXT Record | _dmarc.mail | v=DMARC1; p=none; pct=100; fo=1; ri=3600; rua=mail... |

### Mail Settings ➡️ Custom MX

| Use | Type | Host | Value | Priority |
|-----|------|------|-------|----------|
| MX Record | @    | SMTP.GOOGLE.COM. | 1  |
| MX Record | mail | mxa.mailgun.org. | 10 |
| MX Record | mail | mxb.mailgun.org. | 10 |
