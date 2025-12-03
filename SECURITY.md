# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in My Kit, please report it responsibly.

**Do not open a public GitHub issue for security vulnerabilities.**

Instead, please report via:

1. **GitHub Private Vulnerability Reporting**: Use the "Report a vulnerability" button in the Security tab
2. **Email**: Contact the maintainer directly

### What to Include

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Any suggested fixes (optional)

### Response Timeline

- **Acknowledgment**: Within 48 hours
- **Initial Assessment**: Within 7 days
- **Resolution**: Depends on severity and complexity

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |

## Security Best Practices

When using My Kit:

- Keep your GitHub CLI (`gh`) authenticated securely
- Review commands before execution (use preview mode)
- Don't commit sensitive data (`.gitignore` excludes `.mykit/cache/` and `state.json`)
