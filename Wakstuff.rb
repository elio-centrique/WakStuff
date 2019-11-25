# by Elio-Centrique, All right Reserved 2019

# frozen_string_literal: false
# encoding: UTF-8
# This bot has various commands that show off CommandBot.

require 'json'
require 'discordrb'
require 'discordrb/webhooks'
require 'i18n'
require "google/apis/calendar_v3"
require "googleauth"
require "googleauth/stores/file_token_store"
require "date"
require "fileutils"

#
# GOOGLE CALENDAR INITIALISATION
#
OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
APPLICATION_NAME = "Google Calendar API Ruby Quickstart".freeze
CREDENTIALS_PATH = "credentials.json".freeze
# The file token.yaml stores the user's access and refresh tokens, and is
# created automatically when the authorization flow completes for the first
# time.
TOKEN_PATH = "token.yaml".freeze
SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
  client_id = Google::Auth::ClientId.from_file CREDENTIALS_PATH
  token_store = Google::Auth::Stores::FileTokenStore.new file: TOKEN_PATH
  authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
  user_id = "default"
  credentials = authorizer.get_credentials user_id
  if credentials.nil?
    url = authorizer.get_authorization_url base_url: OOB_URI
    puts "Open the following URL in the browser and enter the " \
         "resulting code after authorization:\n" + url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI
    )
  end
  credentials
end

# Initialize the API
service = Google::Apis::CalendarV3::CalendarService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

file = File.read("config.txt")
file_data = file.split

file = File.read("token.txt")
token = file.split

language = file_data[0]
I18n.load_path << Dir[File.expand_path("locale") + "/*.yml"]
I18n.default_locale = language.to_sym

class Item    
    def initialize(name, rarity, color, level, description, stats, image)
        @name = name
        @rarity = rarity
        @color = color
        @level = level
        @description = description
        @stats = stats
        @image = image
    end

    def name
        @name
    end

    def setName(name)
        @name = name
    end

    def rarity
        @rarity
    end

    def setRarity(rarity)
        @rarity = rarity
    end

    def color
        @color
    end

    def setColor(color)
        @color = color
    end

    def level
        @level
    end

    def setLevel(level)
        @level = level
    end

    def description
        @description
    end

    def setDescription(description)
        @description = description
    end

    def getStats
        message = ""
        for stat in @stats
            message += stat + "\n"
        end
        return message
    end

    def setStats(stats)
        @stats = stats
    end

    def image
        @image
    end
end

listItems = []
fileItem = File.open("JSON/items.json", "r")
jsonItem = JSON.load(fileItem)
fileAction = File.open("JSON/actions.json", "r")
jsonAction = JSON.load(fileAction)

def loadItemList(listItems, jsonItem, jsonAction, language)
    puts "Creation of the item list, it could take some times"
    for item in jsonItem
        rarityNumber = item['definition']['item']['baseParameters']['rarity']
        case rarityNumber
        when 1
            rarity = I18n.t(:common)
            color = 16777215
        when 2
            rarity = I18n.t(:rare)
            color = 65280
        when 3
            rarity = I18n.t(:mythic)
            color = 16750592
        when 4
            rarity = I18n.t(:legendary)
            color = 16776960
        when 5
            rarity = I18n.t(:relic)
            color = 11075839
        when 6
            rarity = I18n.t(:souvenir)
            color = 52991
        when 7
            rarity = I18n.t(:epic)
            color = 16711935
        end
        tmpStats = []
        for bonus in item['definition']['equipEffects']
            bonusId = bonus['effect']['definition']['actionId']
            for action in jsonAction
                if bonusId === action['definition']['id']
                    m = ""
                    param = bonus['effect']['definition']['params']
                    level = item['definition']['item']['level'].to_i
                    if (action['description'] != nil)
                        m = action['description'][language].encode("ISO-8859-1").encode('utf-8')
                        m.gsub! '[~3]?[#1] Maîtrise [#3]:', ""
                        m.gsub! '[~3]?[#1] Mastery [#3]:', ""
                        m.gsub! '[~3]?[#1] Résistance [#3]:', ""
                        m.gsub! '[~3]?[#1] Resistance [#3]:', ""
                        m.gsub! '[#1]', (param[1].to_i * level + param[0].to_i).to_s
                        m.gsub! '[#2]', (param[3].to_i * level + param[2].to_i).to_s
                        m.gsub! '[#3]', (param[5].to_i * level + param[4].to_i).to_s
                        m.gsub! '[>1]?', ""
                        m.gsub! '{[>2]?:s}', "s"
                        m.gsub! '{[>2]?s:}', "s"
                        m.gsub! '{[=2]?:s}', ""
                        m.gsub! '{[=2]?s:}', ""
                        m.gsub! '{[=2]?:}', ""
                        m.gsub! '[~3]?', ""
                        m.gsub! "{", ""
                        m.gsub! "}", ""
                        m.gsub! '[el1]', I18n.t(:fire)
                        m.gsub! '[el2]', I18n.t(:water)
                        m.gsub! '[el3]', I18n.t(:earth)
                        m.gsub! '[el4]', I18n.t(:air)
                        tmpStats.push m
                    end
                end
            end
        end
        description = ""
        if (item['description'] != nil)
            description = "*" + item['description'][language] + "*"
        end
        tmpItem = Item.new(
            item['title'][language], 
            rarity,
            color,
            item['definition']['item']['level'],
            description,
            tmpStats,
            "https://s.ankama.com/www/static.ankama.com/wakfu/portal/game/item/115/" + item['definition']['item']['graphicParameters']['gfxId'].to_s + ".png"
        )
        listItems.push tmpItem
    end
    puts "Itemlist finished, enjoy the bot !"
end

loadItemList(listItems, jsonItem, jsonAction, language)

bot = Discordrb::Commands::CommandBot.new token: token[0], prefix: "w!", advanced_functionality: true

bot.command(:almanax, max_args: 0, description: I18n.t(:almanaxCommand)) do |event|
    message = ""
    calendar_id = "primary"
    response = service.list_events(calendar_id,
                                max_results:   1,
                                single_events: true,
                                order_by:      "startTime",
                                time_min:      DateTime.now.rfc3339)
    message += I18n.t(:almanaxEvent)
    message += I18n.t(:noEventAlmanax) if response.items.empty?
    response.items.each do |eventAlma|
        message += "#{eventAlma.summary}"
    end
    event << event.user.name + I18n.t(:checkDM)
    event.user.pm(message)
end

bot.command(:object, min_args: 2, description: I18n.t(:objectCommand)) do |event, *args|
    fileItem = File.open("JSON/items.json", "r")
    jsonItem = JSON.load(fileItem)
    fileAction = File.open("JSON/actions.json", "r")
    jsonAction = JSON.load(fileAction)
    findObject = false
    findRarity = false
    moreArgs = ""
    level = ""

    if args.length > 2
        moreArgs = args.join(' ')
        moreArgs.slice!(args[0] + ' ')
    else
        moreArgs = args[1]
    end

    for item in listItems
        if moreArgs.downcase === item.name.downcase
            findObject = true
            messageEmbed = ""
            if args[0].downcase == item.rarity.downcase
                findRarity = true
                event.send_embed do |embed|
                    embed.title = item.name + " " +I18n.t(:level) + " " + item.level.to_s
                    embed.description = item.getStats
                    embed.color = item.color
                    embed.add_field(name: "Description: ", value: item.description)
                    embed.image = Discordrb::Webhooks::EmbedImage.new(url: item.image)
                end
            end
        end
    end
    if moreArgs === "Bath Water" || moreArgs === "Elio Bath Water"
        event << "My bath water can be found at Ecaflipus in front of the zaap."
    else
        if !findObject
            event << I18n.t(:noObject)
        end
    end
    if findObject && !findRarity
        event << I18n.t(:noRarity)
    end
end

bot.command(:compare, max_args: 4, description: I18n.t(:compareCommand)) do |event, *args|
    fileItem = File.open("JSON/items.json", "r")
    jsonItem = JSON.load(fileItem)
    fileAction = File.open("JSON/actions.json", "r")
    jsonAction = JSON.load(fileAction)
    findObject1 = false
    findRarity1 = false
    findObject2 = false
    findRarity2 = false

    #item 1
    for item in listItems
        if args[1].downcase === item.name.downcase
            findObject1 = true
            messageEmbed = ""
            if args[0].downcase == item.rarity.downcase
                findRarity1 = true
                event.send_embed do |embed|
                    embed.title = item.name + " " +I18n.t(:level) + " " + item.level.to_s
                    embed.description = item.getStats
                    embed.color = item.color
                    embed.add_field(name: "Description: ", value: item.description)
                    embed.image = Discordrb::Webhooks::EmbedImage.new(url: item.image)
                end
            end
        end
    end
    if !findObject1
        event << args[1] + I18n.t(:noObject)
    end
    if findObject1 && !findRarity1
        event << args[1] + ", " + args[0] + I18n.t(:noRarity)
    end

    #item 2
    for item in listItems
        if args[3].downcase === item.name.downcase
            findObject2 = true
            messageEmbed = ""
            if args[2].downcase == item.rarity.downcase
                findRarity2 = true
                event.send_embed do |embed|
                    embed.title = item.name + " " +I18n.t(:level) + " " + item.level.to_s
                    embed.description = item.getStats
                    embed.color = item.color
                    embed.add_field(name: "Description: ", value: item.description)
                    embed.image = Discordrb::Webhooks::EmbedImage.new(url: item.image)
                end
            end
        end
    end
    if !findObject2
        event << args[3] + I18n.t(:noObject)
    end
    if findObject2 && !findRarity2
        event << args[3] + ", " + args[2] + I18n.t(:noRarity)
    end
end

bot.command(:setLanguage, min_args: 1, max_args: 1, description: I18n.t(:setLanguageCommand)) do |event, *args|
    if(args[0] == "fr" or args[0] == "en")
        conf_file = File.read('config.txt')
        conf_data = conf_file.split
        File.write('config.txt', args[0])
        language = args[0]
        I18n.default_locale = args[0]
        event << I18n.t(:loadingItems)
        loadItemList(listItems, jsonItem, jsonAction, language)
        event << I18n.t(:setLang1) + args[0] + I18n.t(:setLang2)
    else
        event << I18n.t(:wrongLanguage)
    end
end

bot.command(:version, max_args: 0, description: I18n.t(:versionCommand)) do |event|
    file = File.open("version.txt").read
    file.each_line do |line|
        event << line
    end 
end

bot.run