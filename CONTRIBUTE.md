# CONTRIBUTE

Run from the local source code:

```
$ bundle install
$ sudo bundle exec script/run
```

Feel free to submit pull requests. Please document your changes in the description.

## How to test

```
$ cd test/test_app
$ bundle install
$ bundle exec rackup
```

A basic app (only displays "Test app ok" on the root URL - [](localhost:8765)) you can use to check if Pow is correctly setup and Tunnelss correctly working.

You need to have Pow installed (it's a dependency for tunnelss). Go [there](https://pow.cx/).

Setup a Pow config for the test app:

```
$ cd ~/.pow
$ ln -s path/to/repo/tunnelss/test/test_app
```

Check that Pow is correctly configured for the test app:

```
$ curl http://tunnelss_test.dev
```

It should display `Test app ok`. Of course, for now, doing the same curl on the `https` URL would not work. Try it.

```
$ curl http://tunnelss_test.dev
```

It should display `[...] Connection refused`. Nothing is answering on port 443.

Now run tunnelss.

```
sudo bundle exec script/run
```

Again:

```
$ curl https://tunnelss_test.dev
```

Now it should display a long message starting with `SSL certificate problem`, because the root certificate is not recognized. 

```
$ curl --cacert ~/.tunnelss/ca/root.crt https://tunnelss_test.dev
```

Should now display `Test app ok` again :)
