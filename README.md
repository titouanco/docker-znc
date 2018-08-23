# znc

This image is based on [linuxserver/znc](https://github.com/linuxserver/docker-znc).

[ZNC](http://wiki.znc.in/ZNC) is an IRC network bouncer or BNC. It can detach the client from the actual IRC server, and also from selected channels. Multiple clients from different locations can connect to a single ZNC account simultaneously and therefore appear under the same nickname on IRC.

[![znc](http://wiki.znc.in/resources/assets/wiki.png)](http://wiki.znc.in/ZNC)

## Parameters

`The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side.
For example with a port -p external:internal - what this shows is the port mapping from internal to external of the container.
So -p 8080:80 would expose port 80 from inside the container to be accessible from the host's IP on port 8080
http://192.168.x.x:8080 would show you what's running INSIDE the container on port 80.`


* `-p 6501` - the port(s)
* `-v /config` -
* `-e GID` for GroupID - see below for explanation
* `-e UID` for UserID - see below for explanation

For shell access whilst the container is running do `docker exec -it znc sh`.


### User / Group Identifiers

Sometimes when using data volumes (`-v` flags) permissions issues can arise between the host OS and the container. We avoid this issue by allowing you to specify the user `UID` and group `GID`. Ensure the data volume directory on the host is owned by the same user you specify and it will "just work" ™.

In this instance `UID=1001` and `GID=1001`. To find yours use `id user` as below:

```
  $ id <dockeruser>
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

## Setting up the application

To log in to the application, browse to https://<hostip>:6501.

* Default User: admin
* Default Password: admin
`change password ASAP.`

## Info

* Shell access whilst the container is running: `docker exec -it znc sh`
* To monitor the logs of the container in realtime: `docker logs -f znc`

## Versions

+ **23.08.18:** Use alpine 3.8 & buildstage.
+ **03.01.18:** Deprecate cpu_core routine lack of scaling.
+ **07.12.17:** Rebase alpine linux 3.7.
+ **25.10.17:** Remove debug switch from run command.
+ **26.05.17:** Rebase alpine linux 3.6.
+ **06.02.17:** Rebase alpine linux 3.5.
+ **19.01.17:** Add playback module.
+ **07.01.17:** Add ca-certificates package, resolve sasl issues.
+ **07.12.16:** Use scanelf to determine runtime dependencies.
fix error with `\` instead of `&&\`.
+ **14.10.16:** Add version layer information.
+ **30.09.16:** Fix umask.
+ **11.09.16:** Add layer badges to README.
+ **28.08.16:** Add badges to README.
+ **20.08.16:** Rebase to alpine linux,
move to main repository.
+ **11.12.15:** Initial Release.
