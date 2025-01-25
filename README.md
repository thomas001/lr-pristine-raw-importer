# Pristine RAW Importer

A Lightroom plugin that imports photos processed with DxO PureRAW 4. 

This plugin fulfills the same function as the official import plugin that ships
with PureRAW, but it handles the import process differently which fits my
personal workflow better. It tries to move the workflow closer to Lightroom's
builtin "Enhance" workflow. In particular: 

- Processed photos are stacked *above* the source photo
- Develop settings are automatically copied from the source photo
  - Settings related to noise and lens correction are left untouched
- Collections, keywords, color, pick status are copied from the source photo
- *No* new collection is created on every import

## Customization

The plugin has some basic preferences that can be tweaked in Lightroom's plugin
manager:

- How the photo exported from PureRAW is stacked with the source photo
- How collections are updated after export 

## Installation

PureRAW installs two Lightroom plugins: one plugin is responsible for sending
images to PureRAW and starting the program. The other plugin then imports the
processed images back into Lightroom. Only the import plugin is replaced by
Pristine RAW Importer.

1. Download the [latest release](https://github.com/thomas001/lr-pristine-raw-importer/releases/latest/download/plugin.zip) and extract it.

Next go to the Lightroom plugin manager.

2. Disable the `DxO PureRAW 4 Importer` plugin. Keep the `DxO PureRAW 4` plugin enabled! 
   
   <details>
   
     <summary>Screenshot</summary>

     ![Lightroom plugin manager screenshot](docs/plugins.png) 
     
   </details>

3. Add `lr-pristine-raw-importer.lrplugin` as a new plugin
4. Restart Lightroom

## Caveats

- Tested only on my workstation
- Error handling is basic, if a import error occurs the plugin shuts itself down 

## Disclaimers

> DxO and PureRAW are trademarks of DxO Labs. This project is an independent
> tool and is not affiliated with or endorsed by DxO Labs.

> This software is provided "as is", without warranty of any kind, express or
> implied, including but not limited to the warranties of merchantability,
> fitness for a particular purpose, and non-infringement. In no event shall the
> authors or copyright holders be liable for any claim, damages, or other
> liability, whether in an action of contract, tort, or otherwise, arising from,
> out of, or in connection with the software or the use or other dealings in the
> software.
