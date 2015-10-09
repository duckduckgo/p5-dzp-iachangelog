# Dist::Zilla::Plugin::IAChangelog - Add instant answer change log file to releases

## Synopsis

During release, attempts to determine which instant answers have been added,
modified, or deleted.  Outputs their metadata IDs and status to a YAML file.

This file is used by duckpan.org to update the statuses of instant answer pages
on the [DuckDuckHack Community Platform](https://duck.co).

To activate the plugin, add the following to **dist.ini**:

    [IAChangelog]

## Attributes

- **file_name**: Name of the file to be added to the release.  Since this is a YAML file it makes sense to use a .yml extension, though it's not required.  Defaults to 'ia_changelog.yml'.

## Contributing

To browse the repository, submit issues, or bug fixes, please visit
the github repository:

+ https://github.com/duckduckgo/p5-dzp-iachangelog

## Author

Zach Thompson <zach@duckduckgo.com>
