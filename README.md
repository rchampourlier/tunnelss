# Tunnelss

Tunnelss is a proxy from HTTPS to HTTP, which configures its certificate automatically by following [Pow](http://pow.cx/) configuration.

You can use it to complete Pow and run your projects under SSL with a minimal effort!

## Installation

    $ gem install tunnelss

If you're using rbenv:

    $ rbenv rehash

## Run

    $ sudo tunnelss

If you are using rvm:

    $ rvmsudo tunnels

By default, proxy to 80 port from 443 port.

Specify HTTP port and HTTPS port with:

    $ sudo tunnels 443 3000

or

    $ sudo tunnels 127.0.0.1:443 127.0.0.1:3000

## Credits

* [tunnels](https://github.com/jugyo/tunnels) from which most code comes
* [powssl](https://gist.github.com/paulnicholson/2050941), a gist of Paul Nicholson which I translated to Ruby to perform Tunnelss certificate configuration based on Pow's.

## Copyright

[tunnelss](http://github.com/rchampourlier/tunnelss)
Copyright (c) 2013 rchampourlier, released under the MIT license.

[tunnels](https://github.com/jugyo/tunnels)
Copyright (c) 2012 jugyo, released under the MIT license.
