# Balet

Balet is opinionated and minimalist development environment for MacOS. It contains bash scripts for managing Nginx website configurations and domains.

## Table of Contents

* [Requirements](#requirements)
* [Installation](#installation)
* [ Creating Website](#creating-website)
* [ Removing Website](#removing-website)

## Requirements

Before installing Balet, make sure you have installed all of the followings packages.

1. [Git](https://git-scm.com/book/en/v1/Getting-Started-Installing-Git#Installing-on-Mac) — Distributed version control system
2. [Oh My Zsh](http://ohmyz.sh) — Framework for managing Zsh terminal configurations
3. [Homebrew](https://brew.sh) — The package manager for MacOS
4. [Homebrew Nginx ](https://github.com/Homebrew/homebrew-nginx) — Install Nginx server with Homebrew
5. [Dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html) — Lightweight DNS forwarder and DHCP server
6. [Homebrew PHP](https://github.com/Homebrew/homebrew-php) — Install PHP with Homebrew

## Installation

To install Balet, simply open up your terminal application and paste the following command:

```bash
sh -c "$(curl -fsSL https://raw.github.com/risan/balet/master/install.sh)"
```

Once it's completed, your Balet installation will be found on `~/.balet` directory. Next, you may want to reload your `.zshrc` file to get the latest PATH variable:

```bash
source ~/.zshrc
```

The last step is to update your Nginx configuration file. If you are using [Homebrew Nginx ](https://github.com/Homebrew/homebrew-nginx), you will find your configuration file on:

```bash
/usr/local/etc/nginx/nginx.conf
```

Open up your `nginx.conf` file and include the Balet's `servers` directory within the `http` module like below:

```nginx
http {
    ...

    include /Users/YOUR_USER/.balet/servers/*;
}
```

Replace the `YOUR_USER` with your own user account. If you are not sure about your user account name, Balet will also display what line to be added to your `nginx.conf` during completion.

## Creating Website

Once Balet is installed, you can easily create an environment for your website.

```bash
balet add website-type domain [root-dir|port]
```

### The website-type Argument

The `website-type` argument is required and may have the following value:

- `html`: Create an HTML website
- `html-ssl`: Create an HTML website with HTTPS protocol
- `php`: Create a PHP website
- `php-ssl`: Create a PHP website with HTTPS protocol
- `reverse-proxy`: Create reverse proxy server
- `reverse-proxy-ssl`: Create reverse proxy server with HTTPS protocol

### The domain Argument

The `domain` argument is a unique domain name for your development machine, e.g: `test.dev`, `website.dev`

### The root-dir Argument

The `root-dir` is an optional argument for `html`, `html-ssl`, `php`, and `php-ssl` websites. It's the the root directory for the website relative to the project directory.

If the `root-dir` argument is not set, Balet will look for `public` and `html` directory within your project. If those directories are not found, the `root-dir` will be set to your project directory.

### The port Argument

The `port` is an optional argument for `reverse-proxy` and `reverse-proxy-ssl` websites. It's the port number of your proxied application.

If the `port` argument is not set, by default Balet will set it for port number `3000`.

## Removing Website

To remove a website using Balet, simply type the following command:

```bash
balet remove domain
```

The `domain` is the only argument required, it's the domain name of the website that needs to be removed.
