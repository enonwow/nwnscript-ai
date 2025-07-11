/*******************************************************************************
This is some simple NUI menu scripts that have been heavily commented to help
others learn how to script their own NUI menus.

I have create the following menus;
Main menu: Allows access to the other menus plus a fun Teleport and Summos button.
Options menu: to change the main menu and some special effects.
Bug report menu: allowing players to send bug reports straight to the log file.
Character menu: allowing the player to change the portrait and description.
Dice menu: allowing the ability to roll any dice as well as ability scores, saves, and skills.

There are two scripts that will need to be changed!
The first is the OnClientEnter script.
The default script is "x3_mod_def_enter" and I have added it to the erf for
simple insertion to a module that uses the default script.

The second is the event script for player targeting.
If you have your own player targeting event then you will need to change your player targeting script
and remove a line from my "load_nui_menu" script.
It will set the player targeting event to use the script "0e_player_target".
(Thank you Arvirago for pointing out the targeting insertion!)

This should have the following scripts in the erf or module:
00_read_me       - This text file right here!
0e_player_target - Script that runs all targeting events.
0e_window        - Script that runs for all NUI events.
0i_database      - Include scripts for database functions.
0i_main          - Include scripts for important functions.
0i_win_layouts   - Include scripts to create NUI layouts.
0i_window        - Include scripts used by 0i_win_layouts to build NUI elements.
load_nui_menu    - Script that is run in OnClientEnter to create the NUI menus.
x3_mod_def_enter - Default script for OnClientEnter to use or see how to
                   integrate the NUI scripts.

I have also included a NUI scripts folder with the *.nss files as well.

Have fun and Make some cool NUI menus!

Version 1.0 - The entry into this submission.
Version 1.1 - Fixed the collapsable window option. Collapsable windows cannot be binded.
	(Thank you Sacha for catching this!)
Version 1.2 - Fixed dice bonus being off by one. (Thank you Tellenger for catching this!)
	      Fixed dice roller to allow custom skills.2da.
              Fixed portrait sometimes not setting correctly.
	      Added option to remove the title bars.
	      Cleaned up scripts and remarks to make it easier to change.

From the Dalelands of Faerun - A roleplay light server!

Forums: https://essembra.freeforums.net/(link is external)
Discord: discord.gg/RUjMpHxhwj

Philos
*******************************************************************************/

void main()
{

}
