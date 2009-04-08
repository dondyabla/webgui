# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Write a little about what this script tests.
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use Data::Dumper;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Test::Maker::Permission;
use WebGUI::Session;
use WebGUI::Text;
use WebGUI::Utility;
use WebGUI::DateTime;
use DateTime;

################################################################
#
#  setup session, users and groups for this test
#
################################################################

my $session         = WebGUI::Test->session;

my $staff = WebGUI::Group->new($session, 'new');
$staff->name('Reporting Staff');

my $reporter = WebGUI::User->new($session, 'new');
$reporter->username('reporter');
my $editor   = WebGUI::User->new($session, 'new');
$editor->username('editor');
my $reader   = WebGUI::User->new($session, 'new');
$reader->username('reader');
$staff->addUsers([$reporter->userId]);

my $archive = 'placeholder for Test::Maker::Permission';

my $canPostMaker = WebGUI::Test::Maker::Permission->new();
$canPostMaker->prepare({
    object   => $archive,
    session  => $session,
    method   => 'canPostStories',
    pass     => [3, $editor, $reporter ],
    fail     => [1, $reader            ],
});

my $tests = 31
          + $canPostMaker->plan
          ;
plan tests => 1
            + $tests;

#----------------------------------------------------------------------------
# put your tests here

my $class  = 'WebGUI::Asset::Wobject::StoryArchive';
my $loaded = use_ok($class);

my $storage;
my $versionTag;

my $creationDateSth = $session->db->prepare('update asset set creationDate=? where assetId=?');

SKIP: {

skip "Unable to load module $class", $tests unless $loaded;

$archive    = WebGUI::Asset->getDefault($session)->addChild({className => $class, title => 'My Stories', url => '/home/mystories'});
$versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->commit;

isa_ok($archive, 'WebGUI::Asset::Wobject::StoryArchive', 'created StoryArchive');

################################################################
#
#  canPostStories
#
################################################################

$archive->update({
    ownerUserId => $editor->userId,
    groupToPost => $staff->getId,
});

is($archive->get('groupToPost'), $staff->getId, 'set Staff group to post to Story Archive');

$canPostMaker->{_tests}->[0]->{object} = $archive;

$canPostMaker->run();

################################################################
#
#  getFolder
#
################################################################

##Note, this is just to prevent date rollover from happening.
##We'll test implicit getFolder later on.
my $now = time();
my $todayFolder = $archive->getFolder($now);
isa_ok($todayFolder, 'WebGUI::Asset::Wobject::Folder', 'getFolder created a Folder');
is($archive->getChildCount, 1, 'getFolder created a child');
my $dt = DateTime->from_epoch(epoch => $now, time_zone => $session->datetime->getTimeZone);
my $folderName = $dt->strftime('%B_%d_%Y');
$folderName =~ s/^(\w+_)0/$1/;
is($todayFolder->getTitle, $folderName, 'getFolder: folder has the right name');
my $folderUrl = join '/', $archive->getUrl, lc $folderName;
is($todayFolder->getUrl, $folderUrl, 'getFolder: folder has the right URL');
is($todayFolder->getParent->getId, $archive->getId, 'getFolder: created folder has the right parent');
is($todayFolder->get('state'),  'published', 'getFolder: created folder is published');
is($todayFolder->get('status'), 'approved',  'getFolder: created folder is approved');

my $sameFolder = $archive->getFolder($now);
is($sameFolder->getId, $todayFolder->getId, 'call with same time returns the same folder');
undef $sameFolder;

my ($startOfDay, $endOfDay) = $session->datetime->dayStartEnd($now);
$sameFolder = $archive->getFolder($startOfDay);
is($sameFolder->getId, $todayFolder->getId, 'call within same day(start) returns the same folder');
undef $sameFolder;
$sameFolder = $archive->getFolder($endOfDay);
is($sameFolder->getId, $todayFolder->getId, 'call within same day(end) returns the same folder');
undef $sameFolder;
$todayFolder->purge;
is($archive->getChildCount, 0, 'leaving with an empty archive');

################################################################
#
#  addChild
#
################################################################

my $child = $archive->addChild({className => 'WebGUI::Asset::Wobject::StoryTopic'});
is($child, undef, 'addChild: Will only add Stories');

$child = $archive->addChild({className => 'WebGUI::Asset::Story', title => 'First Story'});
isa_ok($child, 'WebGUI::Asset::Story', 'addChild added and returned a Story');
is($archive->getChildCount, 1, 'addChild: added it to the archive');
my $folder = $archive->getFirstChild();
isa_ok($folder, 'WebGUI::Asset::Wobject::Folder', 'Folder was added to Archive');
is($folder->getChildCount, 1, 'The folder has 1 child...');
is($folder->getFirstChild->getTitle, 'First Story', '... and it is the correct child');

################################################################
#
#  viewTemplateVariables
#
################################################################

my $wgBday    = WebGUI::Test->webguiBirthday;
my $oldFolder = $archive->getFolder($wgBday);

my $yesterday = $now-24*3600;
my $newFolder = $archive->getFolder($yesterday);

my ($wgBdayMorn,undef)    = $session->datetime->dayStartEnd($wgBday);
my ($yesterdayMorn,undef) = $session->datetime->dayStartEnd($yesterday);

my $story = $oldFolder->addChild({ className => 'WebGUI::Asset::Story', title => 'WebGUI is released', keywords => 'roger,foxtrot,echo'});
$creationDateSth->execute([$wgBday, $story->getId]);

{
    my $storyDB = WebGUI::Asset->newByUrl($session, $story->getUrl);
    is ($storyDB->get('status'), 'approved', 'addRevision always calls for an autocommit');
}

my $pastStory = $newFolder->addChild({ className => 'WebGUI::Asset::Story', title => "Yesterday is history" });
$creationDateSth->execute([$yesterday, $pastStory->getId]);

my $templateVars;
$templateVars = $archive->viewTemplateVariables();
KEY: foreach my $key (keys %{ $templateVars }) {
    next KEY if isIn($key, qw/canPostStories addStoryUrl date_loop mode/);
    delete $templateVars->{$key};
}

cmp_deeply(
    $templateVars,
    {
        canPostStories => 0,
        mode           => 'view',
        addStoryUrl    => '',
        date_loop      => [
            {
                epochDate => ignore(),
                story_loop => [ {
                    creationDate => ignore(),
                    url          => re('first-story'),
                    title        => 'First Story',
                }, ],
            },
            {
                epochDate => $yesterdayMorn,
                story_loop => [{
                    creationDate => $yesterday,
                    url          => re('yesterday-is-history'),
                    title        => "Yesterday is history",
                }, ],
            },
            {
                epochDate => $wgBdayMorn,
                story_loop => [ {
                    creationDate => $wgBday,
                    url          => '/home/mystories/august_16_2001/webgui-is-released',
                    title        => 'WebGUI is released',
                }, ],
            },
        ]
    },
    'viewTemplateVariables: returns expected template variables with 3 stories in different folders'
);

my $story2 = $folder->addChild({ className => 'WebGUI::Asset::Story', title => 'Story 2', keywords => "roger,foxtrot"});
my $story3 = $folder->addChild({ className => 'WebGUI::Asset::Story', title => 'Story 3', keywords => "foxtrot,echo"});
my $story4 = $folder->addChild({ className => 'WebGUI::Asset::Story', title => 'Story 4', keywords => "roger,echo"});
foreach my $storilet ($story2, $story3, $story4) {
    $session->db->write("update asset set creationDate=$now where assetId=?",[$storilet->getId]);
}
$archive->update({storiesPerPage => 3});

##Don't assume that Admin and Visitor have the same timezone.
$session->user({userId => 3});
($wgBdayMorn,undef)   = $session->datetime->dayStartEnd($wgBday);

$templateVars = $archive->viewTemplateVariables();
KEY: foreach my $key (keys %{ $templateVars }) {
    next KEY if isIn($key, qw/canPostStories addStoryUrl date_loop/);
    delete $templateVars->{$key};
}

cmp_deeply(
    $templateVars,
    {
        canPostStories => 1,
        addStoryUrl    => '/home/mystories?func=add;class=WebGUI::Asset::Story',
        date_loop      => [
            {
                epochDate => ignore(),
                story_loop => [
                    {
                        creationDate => ignore(),
                        url          => re('first-story'),
                        title        => 'First Story',
                    },
                    {
                        creationDate => ignore(),
                        url          => ignore(),
                        title        => 'Story 2',
                    },
                    {
                        creationDate => ignore(),
                        url          => ignore(),
                        title        => 'Story 3',
                    },
                ],
            },
        ],
    },
    'viewTemplateVariables: returns expected template variables with several stories in 3 different folders'
);

TODO: {
    local $TODO = "viewTemplateVariables code to write";
    ok(0, 'Check that Stories from the future are not displayed unless the user canEdit this StoryArchive');
}

################################################################
#
#  viewTemplateVariables, keywords search mode
#
################################################################

$session->request->setup_body({ keyword => 'foxtrot' } );
$archive->update({storiesPerPage => 25});

$templateVars = $archive->viewTemplateVariables('keyword');
is($templateVars->{mode}, 'keyword', 'viewTemplateVariables mode == keyword');
cmp_deeply(
    $templateVars->{date_loop},
    [
        {
            epochDate => ignore(),
            story_loop => [
                {
                    creationDate => ignore(),
                    url          => ignore(),
                    title        => 'Story 2',
                },
                {
                    creationDate => ignore(),
                    url          => ignore(),
                    title        => 'Story 3',
                },
            ],
        },
        {
            epochDate => $wgBdayMorn,
            story_loop => [
                {
                    creationDate => ignore(),
                    url          => ignore(),
                    title        => 'WebGUI is released',
                },
            ],
        },
    ],
    'viewTemplateVariables: keyword mode returns the correct assets in the same form as view mode'
);

$archive->update({storiesPerPage => 3});

$session->request->setup_body({ } );

################################################################
#
#  viewTemplateVariables, search mode
#
################################################################

$session->request->setup_body({ query => 'echo' } );
$archive->update({storiesPerPage => 25});
$templateVars = $archive->viewTemplateVariables('search');
is($templateVars->{mode}, 'search', 'viewTemplateVariables mode == search');

cmp_bag(
    $templateVars->{date_loop},
    [
        {
            epochDate => ignore(),
            story_loop => [
                {
                    creationDate => ignore(),
                    url          => ignore(),
                    title        => 'Story 3',
                },
                {
                    creationDate => ignore(),
                    url          => ignore(),
                    title        => 'Story 4',
                },
            ],
        },
        {
            epochDate => $wgBdayMorn,
            story_loop => [
                {
                    creationDate => ignore(),
                    url          => ignore(),
                    title        => 'WebGUI is released',
                },
            ],
        },
    ],
    'viewTemplateVariables: search mode returns the correct assets in the same form as view mode'
);


################################################################
#
#  tagCloud template variable in view
#
################################################################

$templateVars = $archive->viewTemplateVariables();
my @anchors = simpleHrefParser($templateVars->{keywordCloud});
my @expectedAnchors = ();
foreach my $keyword(qw/echo foxtrot roger/) {
    push @expectedAnchors, [ $keyword, '/home/mystories?func=view;keyword='.$keyword ];
}
cmp_bag(
    \@anchors,
    \@expectedAnchors,
    'keywordCloud template variable has keywords and correct links',
);

################################################################
#
#  RSS and Atom checks
#
################################################################

is($archive->getRssFeedUrl,  '/home/mystories?func=viewRss',  'RSS Feed Url');
is($archive->getAtomFeedUrl, '/home/mystories?func=viewAtom', 'Atom Feed Url');

$archive->update({itemsPerFeed => 3});

cmp_deeply(
    $archive->getRssFeedItems(),
    [
        {
            title => 'First Story',
            description => ignore(),
            'link'      => ignore(),
            date        => ignore(),
            author      => ignore(),
        },
        {
            title => 'Story 2',
            description => ignore(),
            'link'      => ignore(),
            date        => ignore(),
            author      => ignore(),
        },
        {
            title => 'Story 3',
            description => ignore(),
            'link'      => ignore(),
            date        => ignore(),
            author      => ignore(),
        },
    ],
    'rssFeedItems'
);

}

#----------------------------------------------------------------------------
# Cleanup
END {
    if (defined $archive and ref $archive eq $class) {
        $archive->purge;
    }
    if ($versionTag) {
        $versionTag->rollback;
    }
    foreach my $user ($editor, $reporter, $reader) {
        $user->delete if defined $user;
    }
    foreach my $group ($staff) {
        $group->delete if defined $group;
    }
    $creationDateSth->finish;
}

sub simpleHrefParser {
	my ($text) = @_;
	my $p = HTML::TokeParser->new(\$text);
    my @anchors = ();
    while (my $token = $p->get_tag('a')) {
        my $url = $token->[1]{href} || "-";
        my $label = $p->get_trimmed_text("/a");
        push @anchors, [ $label, $url ];
    }
    return @anchors;
}


