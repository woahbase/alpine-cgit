[![build status][251]][232] [![commit][255]][231] [![version:x86_64][256]][235] [![size:x86_64][257]][235] [![version:armhf][258]][236] [![size:armhf][259]][236]

## [Alpine-cGit][234]
#### Container for Alpine Linux + cGit
---

This [image][233] containerizes [cGit][135] running under
a [LigHttpd][136] server to serve locally hosted git repositories.
Can also be used to clone and push/pull the repos using git via
[SSH][137]/PubKey authentication. Scripts included to ease the
tasks e.g creating or mirroring bare repositories, or sync them
periodically.

Based on [Alpine Linux][131] from my [alpine-s6][132] image with
the [s6][133] init system [overlayed][134] in it.

The image is tagged respectively for the following architectures,
* **armhf**
* **x86_64** (retagged as the `latest` )

**armhf** builds have embedded binfmt_misc support and contain the
[qemu-user-static][105] binary that allows for running it also inside
an x64 environment that has it.

---
#### Get the Image
---

Pull the image for your architecture it's already available from
Docker Hub.

```
# make pull
docker pull woahbase/alpine-cgit:x86_64
```

---
#### Configuration Defaults
---

* cGit is deployed at the path `/git/` or `/cgit/`.

* Default configuration listens to ports `80` and `22`(ssh), these
  are published at `64801` and `64822` by default.

* Config file loaded from `/etc/cgitrc` edit or remount this with
  your own. A default is provided which is auto loaded if there
  aren't any config file to start with.

* To keep the same host keys, preserve their contents at `/etc/ssh`.
  These are re-generated if not found.

* Only allows pubkey authentication by default, either use the one
  for the user git, or add your own in
  `/home/git/.ssh/authorized_keys` to get clone and push/pull
  access. Default adds only the pubkey of the `git` user, if
  that does not exist, one set of private/public keys are
  generated.

* Repositories stored at `/home/git/repositories`.

* Web specific stuff, e.g `about.html` or syntax filters should be
  inside `/var/www`, cgit provides some default filters(unused)
  located at `/usr/lib/cgit/`.

---
#### Run
---

If you want to run images for other architectures, you will need
to have binfmt support configured for your machine. [**multiarch**][104],
has made it easy for us containing that into a docker container.

```
# make regbinfmt
docker run --rm --privileged multiarch/qemu-user-static:register --reset
```

Without the above, you can still run the image that is made for your
architecture, e.g for an x86_64 machine..

This images already has a user `git` configured to drop
privileges to the passed `PUID`/`PGID` which is ideal if its used
to run in non-root mode. That way you only need to specify the
values at runtime and pass the `-u alpine` if need be. (run `id`
in your terminal to see your own `PUID`/`PGID` values.)

Running `make` starts the service.

```
# make
docker run --rm -it \
  --name docker_cgit --hostname cgit \
  -c 256 -m 256m \
  -e PGID=1000 -e PUID=1000 \
  -p 64801:80 -p 64822:22 \
  -v data/git:/home/git \
  -v data/ssh:/etc/ssh \
  -v data/web:/var/www \
  -v /etc/hosts:/etc/hosts:ro \
  -v /etc/localtime:/etc/localtime:ro \
  woahbase/alpine-cgit:x86_64
```

create a bare repository with,

```
docker exec -u git -it docker_cgit /scripts/bareinit
```

mirror an existing repository with,

```
docker exec -u git -it docker_cgit /scripts/mirror
```

sync the repositories already tracking with their remote,

```
docker exec -u git -it docker_cgit /scripts/sync
```

Stop the container with a timeout, (defaults to 2 seconds)

```
# make stop
docker stop -t 2 docker_cgit
```

Removes the container, (always better to stop it first and `-f`
only when needed most)

```
# make rm
docker rm -f docker_cgit
```

Restart the container with

```
# make restart
docker restart docker_cgit
```

---
#### Shell access
---

Get a shell inside a already running container,

```
# make shell
docker exec -it docker_cgit /bin/bash
```

set user or login as root,

```
# make rshell
docker exec -u root -it docker_cgit /bin/bash
```

To check logs of a running container in real time

```
# make logs
docker logs -f docker_cgit
```

---
### Development
---

If you have the repository access, you can clone and
build the image yourself for your own system, and can push after.

---
#### Setup
---

Before you clone the [repo][231], you must have [Git][101], [GNU make][102],
and [Docker][103] setup on the machine.

```
git clone https://github.com/woahbase/alpine-cgit
cd alpine-cgit
```
You can always skip installing **make** but you will have to
type the whole docker commands then instead of using the sweet
make targets.

---
#### Build
---

You need to have binfmt_misc configured in your system to be able
to build images for other architectures.

Otherwise to locally build the image for your system.
[`ARCH` defaults to `x86_64`, need to be explicit when building
for other architectures.]

```
# make ARCH=x86_64 build
# sets up binfmt if not x86_64
docker build --rm --compress --force-rm \
  --no-cache=true --pull \
  -f ./Dockerfile_x86_64 \
  --build-arg ARCH=x86_64 \
  --build-arg DOCKERSRC=alpine-s6 \
  --build-arg PGID=1000 \
  --build-arg PUID=1000 \
  --build-arg USERNAME=woahbase \
  -t woahbase/alpine-cgit:x86_64 \
  .
```

To check if its working..

```
# make ARCH=x86_64 test
docker run --rm -it \
  --name docker_cgit --hostname cgit \
  -e PGID=1000 -e PUID=1000 \
  --entrypoint sh \
  woahbase/alpine-cgit:x86_64 \
  -ec 'git version;'
```

And finally, if you have push access,

```
# make ARCH=x86_64 push
docker push woahbase/alpine-cgit:x86_64
```

---
### Maintenance
---

Sources at [Github][106]. Built at [Travis-CI.org][107] (armhf / x64 builds). Images at [Docker hub][108]. Metadata at [Microbadger][109].

Maintained by [WOAHBase][204].

[101]: https://git-scm.com
[102]: https://www.gnu.org/software/make/
[103]: https://www.docker.com
[104]: https://hub.docker.com/r/multiarch/qemu-user-static/
[105]: https://github.com/multiarch/qemu-user-static/releases/
[106]: https://github.com/
[107]: https://travis-ci.org/
[108]: https://hub.docker.com/
[109]: https://microbadger.com/

[131]: https://alpinelinux.org/
[132]: https://hub.docker.com/r/woahbase/alpine-s6
[133]: https://skarnet.org/software/s6/
[134]: https://github.com/just-containers/s6-overlay
[135]: https://git.zx2c4.com/cgit/
[136]: https://www.lighttpd.net/
[137]: https://www.openssh.com/

[201]: https://github.com/woahbase
[202]: https://travis-ci.org/woahbase/
[203]: https://hub.docker.com/u/woahbase
[204]: https://woahbase.online/

[231]: https://github.com/woahbase/alpine-cgit
[232]: https://travis-ci.org/woahbase/alpine-cgit
[233]: https://hub.docker.com/r/woahbase/alpine-cgit
[234]: https://woahbase.online/#/images/alpine-cgit
[235]: https://microbadger.com/images/woahbase/alpine-cgit:x86_64
[236]: https://microbadger.com/images/woahbase/alpine-cgit:armhf

[251]: https://travis-ci.org/woahbase/alpine-cgit.svg?branch=master

[255]: https://images.microbadger.com/badges/commit/woahbase/alpine-cgit.svg

[256]: https://images.microbadger.com/badges/version/woahbase/alpine-cgit:x86_64.svg
[257]: https://images.microbadger.com/badges/image/woahbase/alpine-cgit:x86_64.svg

[258]: https://images.microbadger.com/badges/version/woahbase/alpine-cgit:armhf.svg
[259]: https://images.microbadger.com/badges/image/woahbase/alpine-cgit:armhf.svg
