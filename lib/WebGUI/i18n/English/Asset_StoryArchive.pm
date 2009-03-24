package WebGUI::i18n::English::Asset_StoryArchive;
use strict;

our $I18N = {

    'assetName' => {
        message => q|Story Archive|,
        context => q|An Asset that holds stories.|,
        lastUpdated => 0
    },

    'stories per feed' => {
        message => q|Stories Per Feed|,
        context => q|Label in the edit screen and template.|,
        lastUpdated => 0
    },

    'stories per feed help' => {
        message => q|The number of stories displayed in RSS and Atom feeds from this StoryArchive.|,
        context => q|Hoverhelp in the edit screen and template.|,
        lastUpdated => 0
    },

    'stories per page' => {
        message => q|Stories Per Page|,
        context => q|Label in the edit screen and template.|,
        lastUpdated => 0
    },

    'stories per page help' => {
        message => q|The number of stories displayed on a page.|,
        context => q|Hoverhelp in the edit screen and template.|,
        lastUpdated => 0
    },

    'group to post' => {
        message => q|Group to Post|,
        context => q|Label in the edit screen and template.|,
        lastUpdated => 0
    },

    'group to post help' => {
        message => q|The group allowed to add stories to this Story Archive.|,
        context => q|Hoverhelp in the edit screen and template.|,
        lastUpdated => 0
    },

    'groupToPost' => {
        message => q|The GUID of the group allowed to add stories to this Story Archive.|,
        context => q|Template variable.|,
        lastUpdated => 0
    },

    'template' => {
        message => q|Story Archive Template|,
        context => q|Label in the edit screen and template.|,
        lastUpdated => 0
    },

    'template help' => {
        message => q|The Template used to display the Story Archive.|,
        context => q|Hoverhelp in the edit screen and template.|,
        lastUpdated => 0
    },

    'templateId' => {
        message => q|The GUID of the template used to display the Story Archive.|,
        context => q|Template variable|,
        lastUpdated => 0
    },

    'story template' => {
        message => q|Story Template|,
        context => q|Label in the edit screen and template.|,
        lastUpdated => 0
    },

    'story template help' => {
        message => q|The Template used to display Story assets from this Story Archive.|,
        context => q|Hoverhelp in the edit screen and template.|,
        lastUpdated => 0
    },

    'storyTemplateId' => {
        message => q|The GUID of the template used to display the Story assets.|,
        context => q|Template variable|,
        lastUpdated => 0
    },

    'edit story template' => {
        message => q|Edit Story Template|,
        context => q|Label in the edit screen and template.|,
        lastUpdated => 0
    },

    'edit story template help' => {
        message => q|The Template used to add or edit Story assets.|,
        context => q|Hoverhelp in the edit screen and template.|,
        lastUpdated => 0
    },

    'editStoryTemplateId' => {
        message => q|The GUID of the template used to add or edit Story assets.|,
        context => q|Template variable|,
        lastUpdated => 0
    },

    'archive after' => {
        message => q|Archive Stories After|,
        context => q|Label in the edit screen and template.|,
        lastUpdated => 0
    },

    'archive after help' => {
        message => q|After this time, Story assets will be archived and no longer show up in the list of Stories or feeds.  Set to 0 to disable archiving.|,
        context => q|Hoverhelp in the edit screen and template.|,
        lastUpdated => 0
    },

    'archiveAfter' => {
        message => q|Amount of time in seconds.  After this time, Stories will be archived.|,
        context => q|Template variable|,
        lastUpdated => 0
    },

    'rich editor' => {
        message => q|Rich Editor|,
        context => q|Label in the edit screen and template.|,
        lastUpdated => 0
    },

    'rich editor help' => {
        message => q|The WYSIWIG editor used to edit the content of Story assets.|,
        context => q|Hoverhelp in the edit screen and template.|,
        lastUpdated => 0
    },

    'richEditorId' => {
        message => q|The GUID of the WYSIWIG editor used to edit the content of Story assets.|,
        context => q|Template variable|,
        lastUpdated => 0
    },

    'approval workflow' => {
        message => q|Story Approval Workflow|,
        context => q|Label in the edit screen and template.|,
        lastUpdated => 0,
    },

    'approval workflow help' => {
        message => q|Choose a workflow to be executed on each Story as it gets submitted.|,
        context => q|Hoverhelp in the edit screen and template.|,
        lastUpdated => 0,
    },

    'approvalWorkflowId' => {
        message => q|The GUID of the workflow to be executed on each Story as it gets submitted.|,
        context => q|Template variable|,
        lastUpdated => 0,
    },

    'storyarchive asset template variables title' => {
        message => q|Story Archive Asset Template Variables.|,
        context => q|Title of a help page for asset level template variables.|,
        lastUpdated => 0,
    },

    'view template' => {
        message => q|Story Archive, View Template|,
        context => q|Title of a help page.|,
        lastUpdated => 0,
    },

    'date_loop' => {
        message => q|A loop containing stories in the date they were submitted, with subloops for each day.  The loop is paginated.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'epochDate' => {
        message => q|The epoch that is the beginning of the day for a day where stories were submitted to the Story Archive.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'story_loop' => {
        message => q|A loop containing all stories there were submitted on the day given by epochDate.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'url' => {
        message => q|The URL to view a story.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'title' => {
        message => q|The title of a story.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'creationDate' => {
        message => q|The epoch date when this story was created, or submitted, to the Story Archive.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'add a story' => {
        message => q|Add a Story.|,
        context => q|label for the URL to add a story to the archive.|,
        lastUpdated => 0,
    },

    'searchHeader' => {
        message => q|HTML code for beginning the search form.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'searchForm' => {
        message => q|The text field where users can enter in keywords for the search.|,
        context => q|label for the URL to add a story to the archive.|,
        lastUpdated => 0,
    },

    'searchButton' => {
        message => q|Button with internationalized label for submitting the search form.|,
        context => q|Template variable.|,
        lastUpdated => 0,
    },

    'searchFooter' => {
        message => q|HTML code for ending the search form.|,
        context => q|label for the URL to add a story to the archive.|,
        lastUpdated => 0,
    },

};

1;
