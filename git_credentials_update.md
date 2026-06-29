# Git Credentials Update

### Issue

You tried to pull from a repo, got rejected because the token is expired, and `git` removed the stale token from `~/.git-credentials`.

### Solution

First, generate the new token:
> ▶ Settings
▶ Access
▶ Credentials
▶ Personal access tokens (classic)
▶ Generate new token
▶ Generate new token (classic)
  ▶ Note and expiration as desired
  ▶ **Select scopes:** At least **repo**

Second, copy the token to `~/.git-credentials` as follows:
```
https://luis-i-reyes-castro:<PERSONAL_ACCESS_TOKEN_CLASSIC>@github.com
```