package Finance::btce;

use 5.012004;
use strict;
use warnings;
use JSON;
use Carp qw(croak carp);
use Digest::SHA qw( hmac_sha512_hex);
use WWW::Mechanize;
use Data::Dumper;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Finance::btce ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(BTCtoUSD LTCtoBTC LTCtoUSD ) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw();

our $VERSION = '0.021';

our $post_url = "https://btc-e.com/tapi";
our $ws_url = "https://btc-e.com/api/2/";

sub BTCtoUSD
{
	my $browser = WWW::Mechanize->new(stack_depth => 0, agent => "Linux Mozilla");
	my $json = JSON->new->allow_nonref;
	my $ticker;
	eval { $browser->get("$ws_url" . "btc_usd/ticker"); }; carp $@ if $@;
	if(not $browser->success){
		carp "No Response received.\n";
		return undef;
	}

	eval { $ticker = $json->decode($browser->content)->{ticker}; }; carp $@ if $@;
	return $ticker;
}

sub LTCtoBTC
{
	my $browser = WWW::Mechanize->new(stack_depth => 0, agent => "Linux Mozilla");
	my $json = JSON->new->allow_nonref;
	my $ticker;
	eval { $browser->get("$ws_url" . "ltc_btc/ticker"); }; carp $@ if $@;
	if(not $browser->success){
		carp "No Response received.\n";
		return undef;
	}

	eval { $ticker = $json->decode($browser->content)->{ticker}; }; carp $@ if $@;
	return $ticker;
}

sub LTCtoUSD
{
	my $browser = WWW::Mechanize->new(stack_depth => 0, agent => "Linux Mozilla");
	my $json = JSON->new->allow_nonref;
	my $ticker;
	eval { $browser->get("$ws_url" . "ltc_usd/ticker"); }; carp $@ if $@;
	if(not $browser->success){
		carp "No Response received.\n";
		return undef;
	}

	eval { $ticker = $json->decode($browser->content)->{ticker}; }; carp $@ if $@;
	return $ticker;
}


### Authenticated API calls

sub new
{
	my ($class, $args) = @_;
	if($args->{'apikey'} && $args->{'secret'})
	{
		$args->{mech} = WWW::Mechanize->new(stack_depth => 0, agent => "Linux Mozilla");
		$args->{json} = JSON->new();
		$args->{nonce} = _nonce_closure();
	}
	else
	{
		croak "You must provide an apikey and secret";
	}
	return bless $args, $class;
}


sub getTicker
{
	my ($self, $pair) = @_;
	my $ticker;
	unless($pair){
		carp "Must pass valid currency pair. Ex: btc_usd\n";
		return undef;
	}
	my $url = $ws_url . "$pair/" . "ticker";
	eval { $self->_mech->get($url);}; carp $@ if $@;
	if(not $self->_mech->success() ){
		carp "No success getting data from  $url\n";
		return undef;
	}
	eval { $ticker = $self->_json->decode($self->_mech->content())->{ticker}; }; carp $@ if $@;
	return $ticker;
}


sub getInfo
{
	my ($self) = @_;
	my $nonce = $self->_get_nonce();
	my $data = "method=getInfo&nonce=$nonce";
	$self->_mech->add_header('Key' => $self->_apikey);
	$self->_mech->add_header('Sign' => $self->_hash($data) );
	eval {$self->_mech->post($post_url, ['method' => 'getInfo', 'nonce' => $nonce]); }; carp $@ if $@;
	if(not $self->_mech->success() ){
		carp "No success posting data to $post_url\n";
		return undef;
	}
	my $ref =  $self->_json->decode($self->_mech->content());
	if($ref->{success} != 1){
		carp "Api did not return 'success : 1' from post to $post_url\n";
		return undef;
	}
	return $ref;
}


sub activeOrders
{
  	my ($self) = @_;
	my $nonce = $self->_get_nonce();
	my $data = "method=ActiveOrders&nonce=$nonce";
	$self->_mech->add_header('Key' => $self->_apikey);
	$self->_mech->add_header('Sign' => $self->_hash($data) );
	eval {$self->_mech->post($post_url, ['method' => 'ActiveOrders', 'nonce' => $nonce]); }; carp $@ if $@;
	if(not $self->_mech->success() ){
		carp "No success posting data to $post_url\n";
		return undef;
	}
	my $ref =  $self->_json->decode($self->_mech->content());
	if($ref->{success} != 1 and $ref->{error} ne "no orders"){
		carp "Api did not return 'success : 1' from post to $post_url\n" .
			"Error was: $ref->{error}\n";
		return undef;
	}
	return $ref;

}


sub trade
{
	my ($self, $pair, $type, $rate, $amount) = @_;
	my $nonce = $self->_get_nonce();
	my $data = "method=Trade&nonce=$nonce&pair=$pair&type=$type&rate=$rate&amount=$amount";
	unless($pair and $type and $rate and $amount){
		carp "Must pass valid currency pair (ex.btc_usd), type (buy or sell), rate and amount.\n";
		return undef;
	}
	$self->_mech->add_header('Key' => $self->_apikey);
	$self->_mech->add_header('Sign' => $self->_hash($data) );
	eval { $self->_mech->post($post_url, ['method' => 'Trade', 'nonce' => $nonce, 'pair' => $pair, 
		'type' => $type, 'rate' => $rate, 'amount' => $amount]); }; carp $@ if $@;
	if(not $self->_mech->success() ){
		carp "No success posting data to $post_url\n";
		return undef;
	}
	my $ref =  $self->_json->decode($self->_mech->content());

	if($ref->{success} != 1){
		carp "Api did not return 'success : 1' from post to $post_url\n" .
			"Error was: $ref->{error}\n";
		return undef;
	}

	return $ref;
}


sub cancelOrder
{
	my ($self,$order_id) = @_;
	my $nonce = $self->_get_nonce();
	my $data = "method=CancelOrder&nonce=$nonce&order_id=$order_id";
	$self->_mech->add_header('Key' => $self->_apikey);
	$self->_mech->add_header('Sign' => $self->_hash($data) );
	eval { $self->_mech->post($post_url, ['method' => 'CancelOrder', 'nonce' => $nonce, 'order_id' => $order_id]); }; carp $@ if $@;
	if(not $self->_mech->success() ){
		carp "No success posting data to $post_url\n";
		return undef;
	}
	my $ref =  $self->_json->decode($self->_mech->content());
	if($ref->{success} != 1){
		carp "Api did not return 'success : 1' from post to $post_url\n" .
			"Error was: $ref->{error}\n";
		return undef;
	}

	return $ref;
}


#private methods

sub _apikey
{
	my ($self) = @_;
	return $self->{'apikey'};
}

sub _secretkey
{
	my ($self) = @_;
	return $self->{'secret'};
}

sub _mech
{
	my $self = shift();
	return $self->{mech};
}

sub _json
{
	my $self = shift();
	return $self->{json};
}

sub _hash
{
	my ($self,$data) = @_;
	return hmac_sha512_hex($data, $self->_secretkey() );
}

sub _nonce_closure
{
	my $nonce = time();
	return sub { $nonce++ };
}

sub _get_nonce
{
	my $self = shift();
	return $self->{nonce}->();
}

1;

__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Finance::btce - Perl extension for interfacing with the BTC-e bitcoin exchange

=head1 Version

Version 0.021

=head1 SYNOPSIS

  use Finance::btce;

  my $btce = Finance::btce->new({key => 'key', secret => 'secret',});

#public API calls
  
  #Prices for Bitcoin to USD
  my %price = %{BTCtoUSD()};

  #Prices for Litecoin to Bitcoin
  my %price = %{LTCtoBTC()};
  
  #Prices for Litecoin to USD
  my %price = %{LTCtoUSD()};

#with objects

  #Prices for Bitcoin to USD
  $btce->getTicker('btc_usd');
  
  #account info
  $btce->getInfo();
  
  #make a trade
  $btce->trade('btc_usd', 'sell', 705.5, 1.22);


=head1 DESCRIPTION

C<Finance::btce> is a wrapper module for the btc-e.com webservice.

=head1 METHODS

=head2 new

Create a new C<Finance::btce> object with your api C<apikey> and C<secret>.

  
  my $btce = Finance::btce->new(apikey => 'xxx', secret => 'xxx');
  

=head2 getTicker

Gets current ticker data from API according to pair EX. btc_usd

  
  $btce->getTicker('btc_usd');
  

Returns:

  $VAR1 = {
          'vol_cur' => '16320.89588',
          'vol' => '17038475.28297',
          'avg' => '1047.301485',
          'last' => 1045,
          'sell' => 1045,
          'buy' => '1045.039',
          'high' => '1095.19995',
          'server_time' => 1385845491,
          'low' => '999.40302',
          'updated' => 1385845490
  };
  

On error, returns undef.


=head2 getInfo

Gets current account info from API

  
  $btce->getInfo();
  

Returns:

  $VAR1 = {
          'success' => 1,
          'return' => {
                        'rights' => {
                                      'info' => 1,
                                      'withdraw' => 0,
                                      'trade' => 0
                                    },
                        'funds' => {
                                     'nvc' => 0,
                                     'nmc' => 0,
                                     'btc' => '0.53694401',
                                     'xpm' => 0,
                                     'usd' => '0.35863074',
                                     'ftc' => 0,
                                     'ltc' => 0,
                                     'trc' => 0,
                                     'rur' => 0,
                                     'ppc' => 0,
                                     'eur' => 0
                                   },
                        'server_time' => 1385845686,
                        'open_orders' => 1,
                        'transaction_count' => 108
                      }
  };
  
On error, returns undef.

=head2 activeOrders

Gets any active orders.

  
  $btce->activeOrders();
  

Returns a hash by order_id:

  $VAR1 = {
          'success' => 1,
          'return' => {
                        '72804751' => {
                                        'rate' => '30',
                                        'timestamp_created' => 1385776149,
                                        'amount' => '73.966',
                                        'pair' => 'ltc_usd',
                                        'status' => 0,
                                        'type' => 'buy'
                                      }
                      }
  };
  
On error, returns undef

=head2 trade

Places a trade on the market by pair (ex. btc_usd), type (ex. sell or buy), rate (ex. 980.1), and amount (ex. 2)

  
  $btce->trade('btc_usd', 'buy', 980.1, 2);
  

On success, returns the following hash:

  $VAR1 = {
          'success' => 1,
          'return' => {
                        'funds' => {
                                     'nvc' => 0,
                                     'nmc' => 0,
                                     'btc' => '1.01803021',
                                     'xpm' => 0,
                                     'usd' => '0.30042416',
                                     'ftc' => 0,
                                     'ltc' => '6.98292',
                                     'trc' => 0,
                                     'rur' => 0,
                                     'ppc' => 0,
                                     'eur' => 0
                                   },
                        'remains' => '1.1',
                        'order_id' => 79247481,
                        'received' => 0
                      }
  };
  

On error, returns undef

=head2 cancelOrder

Cancel an active order.

  
  $btce->cancelOrder('79214411');
  

Returns a hash with order_id and funds.

  $VAR1 = {
          'success' => 1,
          'return' => {
                        'funds' => {
                                     'nvc' => 0,
                                     'nmc' => 0,
                                     'btc' => '1.01803021',
                                     'xpm' => 0,
                                     'usd' => '0.30042416',
                                     'ftc' => 0,
                                     'ltc' => '8.08292',
                                     'trc' => 0,
                                     'rur' => 0,
                                     'ppc' => 0,
                                     'eur' => 0
                                   },
                        'order_id' => 79214411
                      }
  };
  
On error, returns undef

=head2 EXPORT

None by default.

=head1 BUGS

Please report all bug and feature requests through github
at L<https://github.com/benmeyer50/Finance-btce/issues>

=head1 AUTHOR

Benjamin Meyer, E<lt>bmeyer@benjamindmeyer.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Benjamin Meyer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
