# Deploy and Host Keycloak on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/keycloak-sso?referralCode=sLjDXb&utm_medium=integration&utm_source=button&utm_campaign=keycloak-sso)

[Keycloak](https://www.keycloak.org/) is the open-source identity and access management server from the Cloud Native Computing Foundation. It adds single sign-on to your apps over OpenID Connect, OAuth 2.0 and SAML 2.0, with user federation (LDAP, Active Directory), social and enterprise login, two-factor authentication, passkeys, fine-grained authorization and a full admin console. This template runs Keycloak 26.8.1 in production mode on its own Postgres 17 and creates the admin account on first boot.

## About Hosting Keycloak

The stack is two services: Keycloak and Postgres.

- **Upstream's image, pinned and pre-built.** Keycloak runs the official `quay.io/keycloak/keycloak` image at a fixed release (26.8.1), not `latest`. The wrapper ([source](https://github.com/two-workspaces/keycloak)) runs Keycloak's own build step for Postgres at image build time, so every boot is `start --optimized` and takes about ten seconds.
- **Production mode behind Railway's TLS.** Keycloak trusts Railway's forwarded headers and uses your Railway domain as its hostname, so tokens, redirects and the login pages all carry the right `https://` URL.
- **Admin on first boot.** The master realm admin is created from `KC_BOOTSTRAP_ADMIN_USERNAME` and the generated `KC_BOOTSTRAP_ADMIN_PASSWORD`, so the public URL never shows an open setup page.
- **Single node, no clustering noise.** Keycloak runs with its local cache, so a redeploy doesn't try to form a cluster with the container it replaces.
- **Bounded memory.** The JVM heap is capped at 768 MB and handed back when idle. Keycloak idles at about 470 MB of RAM and Postgres at about 115 MB, so use the Hobby plan or higher.

## Common Use Cases

- Single sign-on across your internal tools, dashboards and self-hosted apps (Grafana, Outline, GitLab, Nextcloud, Portainer and anything that speaks OIDC or SAML)
- Login, registration, password reset and two-factor authentication for your own web and mobile apps, without building auth
- Connecting an existing LDAP or Active Directory, or Google, GitHub and Microsoft accounts, behind one login
- Replacing Auth0, Okta or Cognito with an identity provider you host yourself

## Dependencies for Keycloak Hosting

- Postgres 17 (included, private network only)

### Deployment Dependencies

- [Keycloak documentation](https://www.keycloak.org/documentation)
- [All configuration options](https://www.keycloak.org/server/all-config)
- [Keycloak on GitHub](https://github.com/keycloak/keycloak)
- [Template source on GitHub](https://github.com/two-workspaces/keycloak)

### Implementation Details

**Sign in.** When the deploy is green, open your Keycloak domain (it opens the admin console) and sign in as `admin` with the password in the Keycloak service's `KC_BOOTSTRAP_ADMIN_PASSWORD` variable. Keycloak calls this a temporary admin and shows a banner until you create a permanent one: in the master realm add a user, set a password, give it the `admin` role, then delete the bootstrap admin.

**Your first app.** Create a realm for your users (keep master for administrators), add a client for each app and point the app at `https://<your domain>/realms/<realm>`. Every realm publishes its OIDC discovery document at `/realms/<realm>/.well-known/openid-configuration`.

**Email.** Password resets and email verification need SMTP, and Railway only allows outbound SMTP on the Pro plan. Set your provider per realm in Realm settings, Email.

**Custom domains.** Add the domain to the Keycloak service in Railway, then set `KC_HOSTNAME` to `https://your.domain` and redeploy. Update your apps' issuer URLs to match.

**Memory.** For many realms, many users or heavy login traffic, raise `-Xmx` in `JAVA_OPTS_KC_HEAP`.

**Upgrading.** Bump the version in both `FROM` lines of the Dockerfile in your fork and redeploy. Keycloak migrates its database on start, so back up Postgres first.

**Back up.** Realms, users, clients and sessions are all in Postgres. Use Railway's volume backups or `pg_dump`.

## Why Deploy Keycloak on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Keycloak on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
