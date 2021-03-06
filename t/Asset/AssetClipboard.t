#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

##The goal of this test is to check the creation and purging of
##versions.

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Asset;
use WebGUI::VersionTag;
use Test::MockObject;
use Test::MockObject::Extends;
use WebGUI::Fork;

use Test::More; # increment this value for each test you create
plan tests => 15;

my $session = WebGUI::Test->session;
$session->user({userId => 3});
my $root = WebGUI::Asset->getRoot($session);
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Asset Clipboard test"});
WebGUI::Test->addToCleanup($versionTag);

my $snippet = $root->addChild({
    url => 'testSnippet',
    title => 'snippet',
    menuTitle => 'snippetMenuTitle',
    className => 'WebGUI::Asset::Snippet',
    snippet   => 'A snippet of text',
}, undef, time()-3);

my $snippetAssetId      = $snippet->getId;
my $snippetRevisionDate = $snippet->get("revisionDate");
my $topFolder = $root->addChild({
    url   => 'TopFolder',
    title => 'TopFolder',
    menuTitle   => 'topFolderMenuTitle',
    groupIdEdit => 3,
    className   => 'WebGUI::Asset::Wobject::Folder',
});
my $folder1a = $topFolder->addChild({
    url   => 'folder_1a',
    title => 'folder1a',
    groupIdEdit => 3,
    className   => 'WebGUI::Asset::Wobject::Folder',
});
my $folder1b = $topFolder->addChild({
    url   => 'folder_1b',
    title => 'folder1b',
    groupIdEdit => 3,
    className   => 'WebGUI::Asset::Wobject::Folder',
});
my $folder1a2 = $folder1a->addChild({
    url   => 'folder_1a2',
    title => 'folder1a2',
    groupIdEdit => 3,
    className   => 'WebGUI::Asset::Wobject::Folder',
});


$versionTag->commit;

my $duplicatedSnippet = $snippet->duplicate;

is($duplicatedSnippet->title,   'snippet',        'duplicated snippet has correct title');
isnt($duplicatedSnippet->getId, $snippetAssetId,  'duplicated snippet does not have same assetId as original');
is( 
    $duplicatedSnippet->revisionDate,
    $snippetRevisionDate,
    'duplicated snippet has the same revision date',
);
is($snippet->getId,                  $snippetAssetId,  'original snippet has correct id');

is($snippet->getParent->getId,           $root->getId, 'original snippet is a child of root');
is($duplicatedSnippet->getParent->getId, $root->getId, 'duplicated snippet is also a child of root');

WebGUI::Test->addToCleanup( $duplicatedSnippet );

####################################################
#
# cut
#
####################################################

note "cut";

is( $topFolder->cut, 1, 'cut: returns 1 if successful' );
is($topFolder->get('state'),              'clipboard', '... state set to trash on the trashed asset object');
is($topFolder->cloneFromDb->get('state'), 'clipboard', '... state set to trash in db on object');
is($folder1a->cloneFromDb->get('state'),  'clipboard-limbo', '... state set to clipboard-limbo on child #1');
is($folder1b->cloneFromDb->get('state'),  'clipboard-limbo', '... state set to clipboard-limbo on child #2');
is($folder1a2->cloneFromDb->get('state'), 'clipboard-limbo', '... state set to clipboard-limbo on grandchild #1-1');

sub is_tree_of_folders {
    my ($asset, $depth, $pfx) = @_;
    my $recursive; $recursive = sub {
        my ($asset, $depth) = @_;
        my $pfx = "    $pfx $depth";
        return 0 unless isa_ok($asset, 'WebGUI::Asset::Wobject::Folder',
            "$pfx: this object");

        my $children = $asset->getLineage(
            ['children'], {
                statesToInclude => ['clipboard', 'clipboard-limbo' ],
                returnObjects   => 1,
            }
        );

        return $depth < 2
            ? is(@$children, 0, "$pfx: leaf childless")
            : is(@$children, 1, "$pfx: has child")
              && $recursive->($children->[0], $depth - 1);
    };

    my $pass = $recursive->($asset, $depth);
    undef $recursive;
    my $message = "$pfx is tree of folders";
    return $pass ? pass $message : fail $message;
}

####################################################
#
# paste
#
####################################################

my $versionTag2 = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->addToCleanup($versionTag2);

my $tempspace = WebGUI::Test->asset;
my $page = $tempspace->addChild({
    className   => 'WebGUI::Asset::Wobject::Layout',
    title       => 'Parent asset',
});

my $shortcut = $tempspace->addChild({
    className           => 'WebGUI::Asset::Shortcut',
    shortcutToAssetId   => $page->getId,
});

$versionTag2->commit;

foreach my $asset ($page, $shortcut, ) {
    $asset = $asset->cloneFromDb;
}

$shortcut->cut;

is $page->paste($shortcut->getId), 0, 'cannot paste a shortcut immediately below the asset it shortcuts';

$shortcut->publish;

$page->cut;

is $shortcut->paste($page->getId), 0, 'cannot paste below shortcuts';

####################################################
#
# pasteInFork
#
####################################################

$session->user({ userId => "3" });
my $process = Test::MockObject::Extends->new( 'WebGUI::Fork' );
$process->mock( "update" => sub { } ); # do nothing on update. we don't care
$process->mock( "session" => sub { return $session } );


# Try with a Collaboration and some Threads
my $tag = WebGUI::VersionTag->getWorking( $session );
WebGUI::Test->addToCleanup($tag);
my $collab = WebGUI::Test->asset(
    className => 'WebGUI::Asset::Wobject::Collaboration',
    groupIdEdit => "3",
);
my $thread = $collab->addChild({
    className => 'WebGUI::Asset::Post::Thread',
    groupIdEdit => "3",
}, undef, undef, { skipAutoCommitWorkflows => 1, skipNotification => 1, },
);
$tag->commit;
$thread = $thread->cloneFromDb;  ##so that the cached parent asset with the wrong status does not update the db.
$thread->cut;
WebGUI::Asset::pasteInFork( $process, { assetId => $collab->getId, list => [ $thread->getId ] } );
$thread = $thread->cloneFromDb;
is( $thread->get('state'), 'published', 'thread is pasted' );
