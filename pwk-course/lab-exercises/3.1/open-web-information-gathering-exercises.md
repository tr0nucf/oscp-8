# Open Web Information Gathering

> 1. Choose an organization and use Google to gather as much information as
possible about it
> 2. Use the Google filetype search operator and look for interesting documents from
the target organization
> 3. Re-do the exercise on your company’s domain. Can you find any data leakage
you were not aware of?

The domain chosen for this exercise is `cisco.com`.

### Example Queries
```
# Get all results from cisco.com
site:cisco.com

# Get all the PDFs
site:cisco.com filetype:pdf

# Look for credentials in PDFs
site:cisco.com filetype:pdf "credential"

# Look for admin pages
site:cisco.com inurl:admin

# Look for config XML files
site:cisco.com filetype:xml "config.xml"
```
Inspiration for the above is from https://www.exploit-db.com/ghdb/5046.
