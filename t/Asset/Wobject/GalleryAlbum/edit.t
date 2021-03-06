# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Test editing a GalleryAlbum from the web interface. Currently, it 
# is tested whether...
# - users can add albums.
# - photos can be rotated.

use strict;
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Test::Mechanize; # Must use this before any other WebGUI modules
use WebGUI::Session;
use Test::Deep;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode( $session );
my @versionTags     = ( WebGUI::VersionTag->getWorking( $session ) );

# Create a user for testing purposes
my $user        = WebGUI::User->new( $session, "new" );
WebGUI::Test->addToCleanup($user);
$user->username( 'dufresne' . time );
my $identifier  = 'ritahayworth';
my $auth        = WebGUI::Operation::Auth::getInstance( $session, $user->authMethod, $user->userId );
$auth->saveParams( $user->userId, $user->authMethod, {
    'identifier'    => Digest::MD5::md5_base64( $identifier ), 
});

my $i18n        = WebGUI::International->new( $session, 'Asset_GalleryAlbum' );

my $gallery 
    = $node->addChild( {
        className           => 'WebGUI::Asset::Wobject::Gallery',
        groupIdAddFile      => '2',     # Registered Users
        workflowIdCommit    => 'pbworkflow000000000003', # Commit Content Immediately
    } );

$versionTags[-1]->commit;
WebGUI::Test->addToCleanup(@versionTags);

#----------------------------------------------------------------------------
# Tests

if ( !eval { require Test::WWW::Mechanize; 1; } ) {
    plan skip_all => 'Cannot load Test::WWW::Mechanize. Will not test.';
}
my $mech    = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok( '/' );

#----------------------------------------------------------------------------
# Visitor user cannot add albums 
$mech->get( $gallery->getUrl('func=add;className=WebGUI::Asset::Wobject::GalleryAlbum') );
ok $mech->res->is_error, 'HTTP error returned from server';
$mech->content_contains( "Permission Denied" );

#----------------------------------------------------------------------------
# Registered User can add albums
$mech->session->user({ user => $user });
WebGUI::Test->addToCleanup($mech->session);

# Complete the GalleryAlbum edit form
my $properties  = {
    title           => 'Gallery Album',
    description     => 'This is a new Gallery Album',
};

$mech->get_ok( $gallery->getUrl('func=add;className=WebGUI::Asset::Wobject::GalleryAlbum') );
$mech->submit_form_ok( {
    with_fields     => $properties,
}, 'Sent GalleryAlbum edit form' );

my $added_tag = WebGUI::VersionTag->getWorking($mech->session);
WebGUI::Test->addToCleanup($added_tag);

# Shows the confirmation page
$mech->content_contains( 
    $i18n->get( 'what next' ),
    'Shows message about what next',
);
$mech->content_contains( 
    q{func=add;className=WebGUI::Asset::File::GalleryFile::Photo},
    'Shows link to add a Photo',
);

# Creates the album with the appropriate properties
my $album   = WebGUI::Asset->newById( $session, $gallery->getAlbumIds->[0] );
cmp_deeply( $properties, subhashof( $album->get ), "Properties from edit form are set correctly" );

SKIP: {

skip 'rotation, deletion, reordering no longer a part of the edit form', 5;

#----------------------------------------------------------------------------
# Photos can be rotated using the respective form buttons

# Use album from previous test
my $album = $gallery->getFirstChild;

# Add single photo to this album. No need to commit since auto-commit was
# enabled for the Gallery asset.
my $tag = WebGUI::VersionTag->getWorking($session);
my $photo
    = $album->addChild({
        className           => "WebGUI::Asset::File::GalleryFile::Photo",
    });
my $photoId = $photo->getId;
$tag->commit;
WebGUI::Test->addToCleanup($tag);

# Attach image file to photo asset (setFile also makes download versions)
$photo->setFile( WebGUI::Test->getTestCollateralPath("rotation_test.png") );
my $storage = $photo->getStorageLocation;

# Save dimensions of images
my @oldDims;
foreach my $file ( @{$storage->getFiles('showAll') } ) {    
    push ( @oldDims, [ $storage->getSizeInPixels($file) ] ) unless $file eq '.';
}

# Rotate photo (i.e. all attached images) by 90° CW
$mech->get_ok( $album->getUrl('func=edit'), 'Request GalleryAlbum edit screen' );
# Select the proper form
$mech->form_name( 'galleryAlbumEdit' );
# Try to click the "rotate right" button
$mech->submit_form_ok( {
    button     => 'rotateRight-' . $photoId,
}, 'Request rotation of photo by 90° CW' );

# Save new dimensions of images in reverse order
my @newDims;
foreach my $file ( @{$storage->getFiles('showAll') } ) {
    push ( @newDims, [ reverse($storage->getSizeInPixels($file)) ] ) unless $file eq '.';
}

# Compare dimensions
cmp_deeply( \@oldDims, \@newDims, "Check if all files were rotated by 90° CW" );

# Rotate photo (i.e. all attached images) by 90° CCW. No need to request the edit view since
# an updated view was returned after the last form submittal.
$mech->form_name( 'galleryAlbumEdit' );
# Try to click the "rotate left" button
$mech->submit_form_ok( {
    button     => 'rotateLeft-' . $photoId,
}, 'Request rotation of photo by 90° CCW' );

# Save new dimensions of images in original order
my @newerDims;
foreach my $file ( @{$storage->getFiles('showAll') } ) {
    push ( @newerDims, [ $storage->getSizeInPixels($file) ] ) unless $file eq '.';
}

# Compare dimensions
cmp_deeply( \@oldDims, \@newerDims, "Check if all files were rotated by 90° CCW" );

}

done_testing;
