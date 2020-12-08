# THIS PLOJECT IS NO LONGER UPDATED. PLEASE CHECK OUT THE V2 OF THE BOT HERE:
# https://github.com/elio-centrique/WakStuff-V2

# WakStuff
<p>WakStuff is a Discord bot for the game Wakfu&copy; created with the JSON data provided by Ankama Games&copy; <br>
WakStuff was developed to give informations about gears, and other usefull features.
</p>

## How to use it
<p>First of all, you need to be an administrator of a server to invite the bot.
If you are, congratulation, you can click on this link to invite the bot: <br/>
https://discordapp.com/oauth2/authorize?client_id=507553140330201089&scope=bot&permissions=0 <br/>
This bot don't need any extra permission, but keep in mind that it needs reading and writing message in channels to work.
</p>

## And then?
<p>That's all, the bot is ready to use, yeah ! </p>

## Commands
<p> Here the list of all the commands available: (the prefix is "w!") <br/>
all arguments between "&lt;&gt;" are mandatory
<ul>
<li> w!version <br/> give the actual version of the bot </li>
<li> w!setLanguage &lt;language> <br/> set the language of the bot. Languages available: fr, en </li>
<li> w!object &lt;rarity&gt; &lt;name&gt; <br/> give the information of one item.</li>
<li> w!compare &lt;rarity1&gt; &lt;name1&gt; &lt;rarity2&gt; &lt;name2&gt; <br/> Compare two items.</li>
<li> w!almanax <br/> give the daily bonus (in PM) </li>
</ul>
More commands will come in the next updates.

## Support
<p> If you need help with the bot (connection issues, usage, suggestions, etc...), you can join the discord server: <br>
https://discord.gg/w5kbMsT <br>
</p>

## Contribution

### Installation
<p>You can contribute to this project by cloning it. <p>
<p>First of all, you need to install a Ruby environment. You can find everything on https://www.ruby-lang.org/en/ <br>
Then, go to the repository folder, open a CMD and type "gem install bundler" (keep it open after the installation) <br>
After that, go to https://discordapp.com/developers/applications and create a new application. <br>
Go to "Bot", configure it and copy the token. <br>
Create a file "token.txt" and paste the token on it. <br>
Finnaly, type "bundle" in the previous cmd to install every dependance.<br>
That's it, the bot is ready to use.<br>
To launch it, type "bundle exec ruby Wakfstuff.rb", and invite your bot on your server by creating a invitation link: <br>
https://discordapi.com/permissions.html (type your Client ID available in your Discord application. The bot don't need any permission.) <br>
</p>

### Github
<p>
The main github repository obey to several rules: <br>
- master & heroku branches are read-only branches. Only me can pull request, commit and push on it. <br>
- heroku branch is a deployment branch for Heroku website. <br>
- develop branch is only a merge branch. Please create a new branch from develop and create a pull request when you need to merge your work. <br>
- you can fork and use the repository as a template. You're free to do wathever you want on it.<br>
<br>
Please respect this rules.
</p>

Wakstuff is owned by Elio-Centrique. All right reserved &copy; 2019
