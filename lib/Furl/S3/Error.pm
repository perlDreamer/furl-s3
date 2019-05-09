package Furl::S3::Error;
use strict;
use Class::Accessor::Lite;
use XML::LibXML;
use overload q{""} => \&stringify;

Class::Accessor::Lite->mk_accessors(qw(code http_code http_status message request_id host_id body));

sub new {
    my( $class, $res ) = @_;
    my $self = bless {
        http_code => $res->{code},
        http_status => $res->{msg},
    }, $class;
    if ( my $xml = $res->{body} ) {
        $self->_parse_xml( $xml );
    }
    $self;
}

sub stringify {
    my $self = shift;
    if ( $self->message ) {
        return sprintf('%s: %s', $self->code, $self->message);
    }
    else {
        return sprintf('HTTP Error: %s %s', $self->http_code, $self->http_status);
    }
}

sub _parse_xml {
    my( $self, $xml ) = @_;
    my $doc = XML::LibXML->new->parse_string( $xml );
    my $code = $doc->findvalue('/Error/Code');
    my $message = $doc->findvalue('/Error/Message');
    my $request_id = $doc->findvalue('/Error/RequestId');
    my $host_id = $doc->findvalue('/Error/HostId');
    $self->body( $xml );
    $self->code( $code );
    $self->message( $message );
    $self->request_id( $request_id );
    $self->host_id( $host_id );
}

1;

__END__

=head1 NAME

Furl::S3::Error - Error object for Furl::S3 responses.

=head1 DESCRIPTION

This little module parses any common error responses from Amazon S3's XML response and provides accessors for them.  It also stores the
original message to help with advanced debugging.

=head1 METHODS

=head2 http_code

HTTP response code from Amazon's S3 servers

=head2 http_status

HTTP status message from Amazon S3.

=head2 code

Amazon S3 specific error code

=head2 message

Amazon S3 specific error message

=head2 request_id

ID of the request as handled by the server (for tracking purposes)

=head2 body

The full, original XML message, for additional debugging.

=head2 host_id

Deprecated, no longer passed as part of S3's response.

=cut

