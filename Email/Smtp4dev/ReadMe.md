# smtp4dev
Fake SMTP server for development, written in .NET. Every message is caught (nothing is delivered) and shown in a
web UI, and the mailbox is also served over IMAP and POP3.<br>
<br>
Web UI: http://localhost:8115<br>
SMTP: `localhost:2525` (from other containers: `smtp4dev:25`), no TLS, no auth needed<br>
IMAP: `localhost:1143` · POP3: `localhost:1110` (any username/password)<br>
<br>
Mailpit (Email/Mailpit) covers most of the same ground and is what the other stacks send to. Use smtp4dev when you
want IMAP/POP3 access (e.g. integration tests that read mail with MailKit) or its message relay rules.

```csharp
// MailKit
using var smtp = new SmtpClient();
await smtp.ConnectAsync("localhost", 2525, SecureSocketOptions.None);
await smtp.SendAsync(message);
```

https://github.com/rnwood/smtp4dev
