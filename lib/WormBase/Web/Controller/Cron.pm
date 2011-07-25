package WormBase::Web::Controller::Cron;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';

sub remove_sessions : Private {
    my ( $self, $c ) = @_;

    my $field = $c->session_store_dbi_expires_field;
    my $rs=  $c->model("Schema::Session")->search({ $field => { '!=', undef },$field => { '<', time },});
    while(my $obj=$rs->next){
	$c->log->debug("delete session:",$obj->session_id);
	$obj->delete();
	$obj->update();
    }
}

1;
