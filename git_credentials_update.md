# Git Credentials Update

### Issue

You tried to pull from a repo, got rejected because the token is expired, and `git` removed the stale token from `~/.git-credentials`.

### Solution

First, generate the new token:
1. [Settings](https://github.com/settings/profile)
2. Left Panel  ▶  Access  ▶  [Credentials](https://github.com/settings/credentials)
3. [Personal access tokens (classic)](https://github.com/settings/tokens)
4. Generate new token ▶ [Generate new token (classic)](https://github.com/settings/tokens/new)
  * Note as desired
  * Expiration as desired
  * **Select scopes:** At least **repo**

Second, copy the token to `~/.git-credentials` as follows:
```
https://luis-i-reyes-castro:<PERSONAL_ACCESS_TOKEN_CLASSIC>@github.com
```
