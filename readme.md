This repository contains a Home Assistant addon that runs **SriAi** on your Home Assistant's machine.
 >**SriAi is an extensible, feature-rich, and user-friendly self-hosted AI platform designed to operate entirely offline.** It supports various LLM runners like **Ollama** and **OpenAI-compatible APIs**, with a **built-in inference engine** for RAG, making it a **powerful AI deployment solution**.

## Installation

1. Go to your [Home Assistant's Addon Store](https://my.home-assistant.io/redirect/supervisor_store/)
2. Click the three dots in the upper right and add the custom repository: `https://github.com/Suryaprakasarao/sriai-homeassistant-addon`
3. Install the **SriAi** add-on from the add-on store.
4. Start the add-on.

## Accessing SriAi

After installing and starting the **SriAi** add-on, you can access it through your Home Assistant URL. By default, it runs on port **8080**. For example: http://homeassistant.local:8080


 >
> ## Key Features of SriAi ⭐
>
> - 🚀 **Effortless Setup**: Runs as a self-contained Home Assistant addon — no extra configuration required to get started.
>
> - 🤝 **Ollama/OpenAI API Integration**: Effortlessly integrate OpenAI-compatible APIs for versatile conversations alongside Ollama models. Customize the OpenAI API URL to link with **LMStudio, GroqCloud, Mistral, OpenRouter, and more**.
>
> - 🛡️ **Granular Permissions and User Groups**: Administrators can create detailed user roles and permissions for a secure, customizable, multi-user environment.
>
> - 📱 **Responsive Design**: Enjoy a seamless experience across Desktop PC, Laptop, and Mobile devices.
>
> - 📱 **Progressive Web App (PWA) for Mobile**: Enjoy a native app-like experience on your mobile device with offline access and a seamless user interface.
>
> - ✒️🔢 **Full Markdown and LaTeX Support**: Elevate your LLM experience with comprehensive Markdown and LaTeX capabilities for enriched interaction.
>
> - 🎤📹 **Hands-Free Voice/Video Call**: Experience seamless communication with integrated hands-free voice and video call features.
>
> - 🛠️ **Model Builder**: Easily create and customize models, characters, and agents directly from the web interface.
>
> - 🐍 **Native Python Function Calling Tool**: Enhance your LLMs with built-in code editor support. Bring Your Own Function (BYOF) by simply adding your pure Python functions.
>
> - 📚 **Local RAG Integration**: Load documents directly into the chat or add files to your document library, accessing them using the `#` command before a query.
>
> - 🔍 **Web Search for RAG**: Perform web searches using providers like `SearXNG`, `Google PSE`, `Brave Search`, `serpstack`, `serper`, `Serply`, `DuckDuckGo`, `TavilySearch`, `SearchApi` and `Bing` and inject the results directly into your chat experience.
>
> - 🌐 **Web Browsing Capability**: Integrate websites into your chat experience using the `#` command followed by a URL.
>
> - 🎨 **Image Generation Integration**: Incorporate image generation using AUTOMATIC1111, ComfyUI (local), or OpenAI's DALL-E (external).
>
> - ⚙️ **Many Models Conversations**: Effortlessly engage with various models simultaneously, harnessing their unique strengths for optimal responses.
>
> - 🔐 **Role-Based Access Control (RBAC)**: Ensure secure access with restricted permissions reserved for administrators.
>
> - 🌐🌍 **Multilingual Support**: Experience SriAi in your preferred language with internationalization (i18n) support.
>
> - 🌟 **Continuous Updates**: SriAi is improved with regular updates, fixes, and new features.


# Configuring this Addon

This addon is functional directly after installing and starting by visiting your homeassistant installation on port 8080. For some features, additional configuration is needed.

## Microphone Access

Most web browsers block microphone access on non-secure (HTTP) sites. This means that if your Home Assistant URL isn’t using HTTPS, the speech-to-text features won’t work. To enable these features, you’ll need to secure your connection. One way to do this is by hosting SriAi on a subdomain and configuring SSL through the NGINX Homeassistant Addon (see the next section).

## Internet Access

If you want to access your SriAi instance from outside your Home Assistant's local network, you will want to configure SSL. This is best done by giving SriAi its own subdomain on your Home Assistant's domain.

---

## Example Setup: Hosting SriAi on a Subdomain with SSL

Hosting SriAi on a subdomain allows you to secure your connection with HTTPS. In this example, we use the NGINX add-on together with the Let's Encrypt Home Assistant add-on.

> **Warning:** This configuration makes SriAi publicly accessible. Use it at your own risk and be sure to set a strong password.

### Prerequisites

- **Local Access:** Verify that you can reach SriAi on your local Home Assistant domain (e.g., `http://homeassistant.local:8080`).

---

### DNS Configuration

If your Home Assistant instance is reachable at `myhome.com` and you want to serve SriAi from `chat.myhome.com`, add a CNAME DNS record for your subdomain.

**Example DNS Record:**

- **CNAME:** `chat.myhome.com` → `myhome.com`

---

### Set Up SSL for the Subdomain

This guide assumes you already have SSL enabled for your Home Assistant domain via the Let's Encrypt add-on. To secure your subdomain:

1. **Add the Subdomain:**  
   Open your Let's Encrypt settings and include your subdomain (e.g., `chat.myhome.com`) in the domains field.

2. **Run Let's Encrypt:**  
   Start the Let's Encrypt add-on and verify that the process completes successfully.

3. **Confirm Files:**  
   If successful, you should see the following files on your system:
   - `/ssl/fullchain.pem`
   - `/ssl/privkey.pem`
   *Note: This setup was tested using the HTTP validation method.*

---

### Configure NGINX for the Subdomain

Now, configure the NGINX Home Assistant add-on so that requests to your subdomain are forwarded to SriAi.

1. **Enable Custom Configuration:**
    In the NGINX add-on settings, enable the **Customize** option by setting `active` to `true`.
    The `server` property (indicating where NGINX will look for configuration files) can usually remain at its default value.


2. **Create a Subdomain Configuration File:**
   On your Home Assistant system, create a directory named `nginx_proxy` if it doesn’t already exist.
   Create a file at the following location:
    ```
    /share/nginx_proxy/chat.myhome.com.conf
    ```

3. **Add the Following Configuration:**
```
# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name chat.myhome.com;
    return 301 https://$host$request_uri;
}
server {
    listen 443 ssl;
    server_name chat.myhome.com;
    ssl_certificate /ssl/fullchain.pem;
    ssl_certificate_key /ssl/privkey.pem;
    
    # Optional security headers
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options "SAMEORIGIN";
    add_header Referrer-Policy "no-referrer-when-downgrade";
    location / {
        # Forward requests to your SriAi instance
        proxy_pass http://homeassistant.local:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Enable WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

   **Tip:** If your local SriAi address differs from `http://homeassistant.local:8080`, update the `proxy_pass` URL accordingly.

---

Once this configuration is in place, you can access SriAi securely via your subdomain:

https://chat.myhome.com
