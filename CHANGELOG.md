## 3.0.4
* Added window size reset option. Added some additional safeguards to make sure window doesn't get accidentally resized too big.
** See new slash command **/dressup resetsize** to reset window size.

## 3.0.3
* Fixed string find error in custom link handling causing errors with other addons.

## 3.0.2
* Moved Heart of Azeroth rank frame on character panel so that it doesn't overlap with item level number.

## 3.0.1
* Fixed player model frame not taking up the whole space on the dressing room window.

## 3.0.0
* Updated for Battle for Azeroth.
* Added option to hide DressUp buttons on character panel.
* Added support for the new allied races.

## 2.3.3
* Added missing allied race background images.
* Added the class based background images. Use CTRL+Mouse wheel to switch the background.

## 2.3.2
* Added allied races to the preview drop down menu.
* Made the custom dress up frame movable. Thanks fuda01.
* Added option to always start previews undressed.
	* Be aware combined with race previews the new armor sets with 3D gadgets seem to remain on model and there is nothing that can be done about it.

## 2.3.1
* Fixed incorrect artifact item level being displayed after upgrading one in the Netherlight Crucible.

## 2.3.0
* TOC bump for 7.3.0.
* Applied fix to PlaySound errors (provided by Bramvangemert @ Github).

## 2.2.4
* TOC bump for 7.2.0.

## 2.2.3
* TOC bump for 7.1.0.

## 2.2.2
* Like really really fixed artifact item level display (hiding offhand item level when no offhand).

## 2.2.1
* Really fixed artifact item level display.

## 2.2.0
* Added a way to whisper currently previewed items to other people.
* Added slash command to open the dressing room. Type /dressup or /dressingroom.
* Fixed weirdness with weapon previews.

## 2.1.7
* Fixed a bug in previous update.

## 2.1.6
* Fixed offhand item level number when using artifact weapons.

## 2.1.5
* Fixed error with item level updating.

## 2.1.4
* Added option to keep item levels permanently visible.
* Colorizing item levels by range. Lowest item levels are colored orange while higher end blue. Colorizing can be disabled in the options.
* Fixed error with side panel background.

## 2.1.3
* Revert the background change (again) and reinclude the Blizzard assets.

## 2.1.2
* Switched background images to use Blizzard Transmogrify textures so that the addon doesn't have to distribute Blizzard assets.
* Added option to always hide shirt.
* Other minor tweaks.

## 2.1.1
* Added help info about proper updating of addon.
* Added hint to emphasize the new resize feature.
* Aligned interface elements around slightly.

## 2.1.0
* Fixed bug introduced by the previous fix causing weapon slots not to be updated properly.
* Dressing room window is now resizable.
	* But for a price (from the development standpoint). DressUp now has to overwrite Blizzard dressing room frames with its own which may cause conflicts with other addons that may tweak the default Blizzard frames.
	* Following frames are overwritten: DressUpFrame, DressUpFrameOutfitDropDown, DressUpFrameResetButton, DressUpModel, DressUpFrameCancelButton. Old frames are still accessible by prefixing frame name with "Blizz" e.g. BlizzDressUpFrame.

## 2.0.1
* Fixed nil error when previewing saved outfits.

## 2.0.0
* Updated for Legion:
  * Added support for the outfits and new outfit dropdown.
  * With a proper way to retrieve previewed items, the weapon preview ordering is finally fixed.
  * Removed helm and cloak toggles since they're now changeable by transmog only (:angry fist: at Blizzard).

## 1.2.0
* Added options to automatically hide currently worn tabard and weapons when previewing items.

## 1.1.0
* Added an option to hide the display of item levels on character panel.
* Added an option to hide the display of helm and cloak toggle checkboxes on character panel.
* Added options menu button to character panel.
