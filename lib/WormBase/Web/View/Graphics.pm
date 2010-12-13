package WormBase::Web::View::Graphics;
 
use Moose;
extends 'Catalyst::View::GD';
__PACKAGE__->config({
  gd_image_type         => 'jpg',        # defaults to 'gif'
          gd_image_content_type => 'images/jpg', # defaults to 'image/$gd_image_type'
          
 });

1;

