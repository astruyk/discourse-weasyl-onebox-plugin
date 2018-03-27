# discourse-weasyl-onebox-plugin
Plugin for Discourse to embed previews of Weasyl submissions.

## Installation
* Add the plugin's repository URL to the end of the Discourse container's `app.xml` file (in `/var/discourse/containers/app.xml`). For example:
```
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - mkdir -p plugins
          - git clone https://github.com/discourse/docker_manager.git
          - git clone https://github.com/astruyk/discourse-weasyl-onebox-plugin.git
```

* Rebuild the webpage
```
cd /var/discourse
./launcher rebuild app
```

* (optional) Rebuild the existing posts so that existing posts will use the new OneBox:
```
./launcher enter app
rake posts:rebake
```

That's it!
