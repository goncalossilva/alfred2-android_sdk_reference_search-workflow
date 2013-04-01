# Android SDK Reference Search #

Search the Android SDK class and XML references directly in Alfred 2.

## Demo ##

![Demo](https://raw.github.com/goncalossilva/alfred2-android_sdk_reference_search-workflow/master/screenshots/demo.gif)

## Install ##

Download the [Android SDK Reference Search.alfredworkflow](https://github.com/goncalossilva/alfred2-android_sdk_reference_search-workflow/raw/master/Android%20SDK%20Reference%20Search.alfredworkflow) and import it in Alfred 2.

## Usage ##

Type `ad` followed by a query to do real-time filtering of all class names or XML references that match your query in the Android SDK.

For example, if you type `ad ImageView` this is what you'll see: ![ad ImageView](https://raw.github.com/goncalossilva/alfred2-android_sdk_reference_search-workflow/master/screenshots/ad_ImageView.png)

Make sure to press the shift key on your keyboard while highlighting the list item you're interested in if you just want a glimpse of the documentation (behaves like in the demo above, thanks to Alfred).

If you just type `ad` (no argument) and select "Android SDK Reference", your default browser will open on Android's main page for the SDK reference.

## Requirements ##

The filtering part of the workflow is written in Ruby. This shouldn't be a problem for anyone since OS X ships with Ruby, but let me know if you hit any trouble.

## Acknowledgements ##

[Roman Nurik](https://twitter.com/romannurik), for creating the [Android SDK Reference Search chrome extension](https://chrome.google.com/webstore/detail/android-sdk-reference-sea/hgcbffeicehlpmgmnhnkjbjoldkfhoin). Besides being a fantastic extension, it served as the base for this Alfred workflow.