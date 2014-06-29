[![Build Status](https://travis-ci.org/benmeyer50/Finance-btce.png?branch=master)](https://travis-ci.org/benmeyer50/Finance-btce)

Finance-btce version 0.04
=========================

The README is used to introduce the module and provide instructions on
how to install the module, any machine dependencies it may have (for
example C compilers and installed libraries) and any other information
that should be provided before the module is installed.

A README file is required for CPAN modules since CPAN extracts the
README file from a module distribution so that people browsing the
archive can use it get an idea of the modules uses. It is usually a
good idea to provide version information here so that people can
decide whether fixes for the module are worth downloading.

INSTALLATION

To install this module type the following:

   perl Makefile.PL
   make
   make test
   make install


<ul id="index">
  <li><a href="#NAME">NAME</a></li>
  <li><a href="#Version">Version</a></li>
  <li><a href="#SYNOPSIS">SYNOPSIS</a></li>
  <li><a href="#DESCRIPTION">DESCRIPTION</a></li>
  <li><a href="#METHODS">METHODS</a>
    <ul>
      <li><a href="#new">new</a></li>
      <li><a href="#getTicker">getTicker</a></li>
      <li><a href="#getInfo">getInfo</a></li>
      <li><a href="#activeOrders">activeOrders</a></li>
      <li><a href="#trade">trade</a></li>
      <li><a href="#cancelOrder">cancelOrder</a></li>
      <li><a href="#EXPORT">EXPORT</a></li>
    </ul>
  </li>
  <li><a href="#BUGS">BUGS</a></li>
  <li><a href="#AUTHOR">AUTHOR</a></li>
  <li><a href="#COPYRIGHT-AND-LICENSE">COPYRIGHT AND LICENSE</a></li>
</ul>

<h1 id="NAME">NAME</h1>

<p>Finance::btce - Perl extension for interfacing with the BTC-e bitcoin exchange</p>

<h1 id="Version">Version</h1>

<p>Version 0.04</p>

<h1 id="SYNOPSIS">SYNOPSIS</h1>

<pre><code>  use Finance::btce;

  my $btce = Finance::btce-&gt;new({key =&gt; &#39;key&#39;, secret =&gt; &#39;secret&#39;,});</code></pre>

<p>#public API calls</p>

<pre><code>  #Prices for Bitcoin to USD
  my %price = %{BTCtoUSD()};

  #Prices for Litecoin to Bitcoin
  my %price = %{LTCtoBTC()};
  
  #Prices for Litecoin to USD
  my %price = %{LTCtoUSD()};</code></pre>

<p>#with objects</p>

<pre><code>  #Prices for Bitcoin to USD
  $btce-&gt;getTicker(&#39;btc_usd&#39;);
  
  #account info
  $btce-&gt;getInfo();
  
  #make a trade
  $btce-&gt;trade(&#39;btc_usd&#39;, &#39;sell&#39;, 705.5, 1.22);</code></pre>

<h1 id="DESCRIPTION">DESCRIPTION</h1>

<p><code>Finance::btce</code> is a wrapper module for the btc-e.com webservice.</p>

<h1 id="METHODS">METHODS</h1>

<h2 id="new">new</h2>

<p>Create a new <code>Finance::btce</code> object with your api <code>apikey</code> and <code>secret</code>.</p>

<pre><code>  my $btce = Finance::btce-&gt;new(apikey =&gt; &#39;xxx&#39;, secret =&gt; &#39;xxx&#39;);
  </code></pre>

<h2 id="getTicker">getTicker</h2>

<p>Gets current ticker data from API according to pair EX. btc_usd</p>

<pre><code>  $btce-&gt;getTicker(&#39;btc_usd&#39;);
  </code></pre>

<p>Returns:</p>

<pre><code>  $VAR1 = {
          &#39;vol_cur&#39; =&gt; &#39;16320.89588&#39;,
          &#39;vol&#39; =&gt; &#39;17038475.28297&#39;,
          &#39;avg&#39; =&gt; &#39;1047.301485&#39;,
          &#39;last&#39; =&gt; 1045,
          &#39;sell&#39; =&gt; 1045,
          &#39;buy&#39; =&gt; &#39;1045.039&#39;,
          &#39;high&#39; =&gt; &#39;1095.19995&#39;,
          &#39;server_time&#39; =&gt; 1385845491,
          &#39;low&#39; =&gt; &#39;999.40302&#39;,
          &#39;updated&#39; =&gt; 1385845490
  };
  </code></pre>

<p>On error, returns undef.</p>

<h2 id="getInfo">getInfo</h2>

<p>Gets current account info from API</p>

<pre><code>  $btce-&gt;getInfo();
  </code></pre>

<p>Returns:</p>

<pre><code>  $VAR1 = {
          &#39;success&#39; =&gt; 1,
          &#39;return&#39; =&gt; {
                        &#39;rights&#39; =&gt; {
                                      &#39;info&#39; =&gt; 1,
                                      &#39;withdraw&#39; =&gt; 0,
                                      &#39;trade&#39; =&gt; 0
                                    },
                        &#39;funds&#39; =&gt; {
                                     &#39;nvc&#39; =&gt; 0,
                                     &#39;nmc&#39; =&gt; 0,
                                     &#39;btc&#39; =&gt; &#39;0.53694401&#39;,
                                     &#39;xpm&#39; =&gt; 0,
                                     &#39;usd&#39; =&gt; &#39;0.35863074&#39;,
                                     &#39;ftc&#39; =&gt; 0,
                                     &#39;ltc&#39; =&gt; 0,
                                     &#39;trc&#39; =&gt; 0,
                                     &#39;rur&#39; =&gt; 0,
                                     &#39;ppc&#39; =&gt; 0,
                                     &#39;eur&#39; =&gt; 0
                                   },
                        &#39;server_time&#39; =&gt; 1385845686,
                        &#39;open_orders&#39; =&gt; 1,
                        &#39;transaction_count&#39; =&gt; 108
                      }
  };
  </code></pre>

<p>On error, returns undef.</p>

<h2 id="activeOrders">activeOrders</h2>

<p>Gets any active orders.</p>

<pre><code>  $btce-&gt;activeOrders();
  </code></pre>

<p>Returns a hash by order_id:</p>

<pre><code>  $VAR1 = {
          &#39;success&#39; =&gt; 1,
          &#39;return&#39; =&gt; {
                        &#39;72804751&#39; =&gt; {
                                        &#39;rate&#39; =&gt; &#39;30&#39;,
                                        &#39;timestamp_created&#39; =&gt; 1385776149,
                                        &#39;amount&#39; =&gt; &#39;73.966&#39;,
                                        &#39;pair&#39; =&gt; &#39;ltc_usd&#39;,
                                        &#39;status&#39; =&gt; 0,
                                        &#39;type&#39; =&gt; &#39;buy&#39;
                                      }
                      }
  };
  </code></pre>

<p>On error, returns undef</p>

<h2 id="trade">trade</h2>

<p>Places a trade on the market by pair (ex. btc_usd), type (ex. sell or buy), rate (ex. 980.1), and amount (ex. 2)</p>

<pre><code>  $btce-&gt;trade(&#39;btc_usd&#39;, &#39;buy&#39;, 980.1, 2);
  </code></pre>

<p>On success, returns the following hash:</p>

<pre><code>  $VAR1 = {
          &#39;success&#39; =&gt; 1,
          &#39;return&#39; =&gt; {
                        &#39;funds&#39; =&gt; {
                                     &#39;nvc&#39; =&gt; 0,
                                     &#39;nmc&#39; =&gt; 0,
                                     &#39;btc&#39; =&gt; &#39;1.01803021&#39;,
                                     &#39;xpm&#39; =&gt; 0,
                                     &#39;usd&#39; =&gt; &#39;0.30042416&#39;,
                                     &#39;ftc&#39; =&gt; 0,
                                     &#39;ltc&#39; =&gt; &#39;6.98292&#39;,
                                     &#39;trc&#39; =&gt; 0,
                                     &#39;rur&#39; =&gt; 0,
                                     &#39;ppc&#39; =&gt; 0,
                                     &#39;eur&#39; =&gt; 0
                                   },
                        &#39;remains&#39; =&gt; &#39;1.1&#39;,
                        &#39;order_id&#39; =&gt; 79247481,
                        &#39;received&#39; =&gt; 0
                      }
  };
  </code></pre>

<p>On error, returns undef</p>

<h2 id="cancelOrder">cancelOrder</h2>

<p>Cancel an active order.</p>

<pre><code>  $btce-&gt;cancelOrder(&#39;79214411&#39;);
  </code></pre>

<p>Returns a hash with order_id and funds.</p>

<pre><code>  $VAR1 = {
          &#39;success&#39; =&gt; 1,
          &#39;return&#39; =&gt; {
                        &#39;funds&#39; =&gt; {
                                     &#39;nvc&#39; =&gt; 0,
                                     &#39;nmc&#39; =&gt; 0,
                                     &#39;btc&#39; =&gt; &#39;1.01803021&#39;,
                                     &#39;xpm&#39; =&gt; 0,
                                     &#39;usd&#39; =&gt; &#39;0.30042416&#39;,
                                     &#39;ftc&#39; =&gt; 0,
                                     &#39;ltc&#39; =&gt; &#39;8.08292&#39;,
                                     &#39;trc&#39; =&gt; 0,
                                     &#39;rur&#39; =&gt; 0,
                                     &#39;ppc&#39; =&gt; 0,
                                     &#39;eur&#39; =&gt; 0
                                   },
                        &#39;order_id&#39; =&gt; 79214411
                      }
  };
  </code></pre>

<p>On error, returns undef</p>

<h2 id="EXPORT">EXPORT</h2>

<p>None by default.</p>

<h1 id="BUGS">BUGS</h1>

<p>Please report all bug and feature requests through github at <a href="https://github.com/benmeyer50/Finance-btce/issues">https://github.com/benmeyer50/Finance-btce/issues</a></p>

<h1 id="AUTHOR">AUTHOR</h1>

<p>Benjamin Meyer, &lt;bmeyer@benjamindmeyer.com&gt;</p>

<h1 id="COPYRIGHT-AND-LICENSE">COPYRIGHT AND LICENSE</h1>

<p>Copyright (C) 2013 by Benjamin Meyer</p>

<p>This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself, either Perl version 5.12.4 or, at your option, any later version of Perl 5 you may have available.</p>



