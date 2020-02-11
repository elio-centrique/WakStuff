# by Elio-Centrique, All right Reserved 2019

# frozen_string_literal: false
# encoding: UTF-8
# This bot has various commands that show off CommandBot.

require 'json'
require 'discordrb'
require 'discordrb/webhooks'
require 'i18n'
require "date"
require 'mongo'
require_relative "Classes/Item.rb"

#file = File.read("token.txt")
token = ENV["token"]

I18n.load_path << Dir[File.expand_path("locale") + "/*.yml"]
I18n.default_locale = "en"

$listItemsFR = []
$listItemsEN = []

$exampleSort = [31, 56, 41, 57, 191, 192, 161, 160, 184, 20, 166, 162, 167, 163, 175, 174, 173, 174, 176, 171, 150, 168, 126, 875, 120, 130, 122, 132, 123, 124, 125, 149, 151, 1068, 26, 180, 181, 1050, 1051, 1052, 1053, 1055, 1056, 1060, 1061, 80, 100, 1069, 82, 97, 83, 98, 84, 96, 85, 71, 988, 1062, 1063, 234, 2000, 2001, 2002, 2006, 2008]
client = Mongo::Client.new('mongodb+srv://' + ENV['db_user'] + ":" + ENV['db_pass'] + "@" + ENV['db_name'] + "-l6ey6.gcp.mongodb.net/test?retryWrites=true&w=majority", :database => 'Wakstuff', :monitoring => false)
collection = client[:guilds]

def checkLanguage(event, client)
    #check language
    id_server = event.server.id
    id_found = false
    language = ""
    /
    File.open("config.txt", "r+") { |file_lang|
        file_lang.each_line do |line|
            if id_server.to_s == line.split(":")[0]
                id_found = true
                language = line.split(":")[1]
            end
        end
        if(id_found == false)
            language = "en"
            file_lang.write(id_server.to_s + ":" + language + "\n")
        end
    }
    /
    puts client[:guilds].find({"id_server" => id_server}).first()
    language = "fr"
    listItem = nil
    (language == "fr") ? listItem = $listItemsFR : listItem = $listItemsEN
    I18n.locale = language
    return listItem
end

def loadItemList()
    puts "Creation of the item list, it could take some times"
    fileItem = File.open("JSON/items.json", "r")
    jsonItem = JSON.load(fileItem)
    fileAction = File.open("JSON/actions.json", "r")
    jsonAction = JSON.load(fileAction)

    jsonItem.each { |item|
        rarityNumber = item['definition']['item']['baseParameters']['rarity']
        I18n.locale = "fr"
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
        item['definition']['equipEffects'].each { |bonus|
            bonusId = bonus['effect']['definition']['actionId']
            jsonAction.each { |action|
                if bonusId === action['definition']['id']
                    m = ""
                    param = bonus['effect']['definition']['params']
                    level = item['definition']['item']['level'].to_i
                    if item['definition']['item']['baseParameters']['itemTypeId'] == 582
                        level += 50
                    end
                    if action['description'] != nil
                        m = action['description']["fr"].encode('utf-8')
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
                        tmpStats.push [bonusId,
                                       param[1].to_i * level + param[0].to_i,
                                       param[3].to_i * level + param[2].to_i,
                                       param[5].to_i * level + param[4].to_i,
                                       m
                        ]
                    end
                end
            }
        }
        description = ""
        if item['description'] != nil
            description = "*" + item['description']["fr"] + "*"
        end
        sortedStats = []
        $exampleSort.each_with_index { |idExample, indexExample|
            tmpStats.each { |stat|
                if stat[0] == idExample
                    sortedStats[indexExample] = stat
                end
            }
        }

        sortedStats = sortedStats.reject! {|stat| stat.nil? }
        (item['title'] != nil) ? title = item['title']["fr"] : title = "undefined"
        level = item['definition']['item']['level'].to_i
        if item['definition']['item']['baseParameters']['itemTypeId'] == 582
            level += 50
        end
        tmpItem = Item.new(
            title,
            rarity,
            color,
            level,
            description,
            sortedStats,
            "https://s.ankama.com/www/static.ankama.com/wakfu/portal/game/item/115/" + item['definition']['item']['graphicParameters']['gfxId'].to_s + ".png"
        )
        $listItemsFR.push tmpItem
    }

    jsonItem.each { |item|
        rarityNumber = item['definition']['item']['baseParameters']['rarity']
        I18n.locale = "en"
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
        item['definition']['equipEffects'].each { |bonus|
            bonusId = bonus['effect']['definition']['actionId']
            jsonAction.each { |action|
                if bonusId === action['definition']['id']
                    m = ""
                    param = bonus['effect']['definition']['params']
                    level = item['definition']['item']['level'].to_i
                    if item['definition']['item']['baseParameters']['itemTypeId'] == 582
                        level += 50
                    end
                    if action['description'] != nil
                        m = action['description']["en"].encode('utf-8')
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
                        tmpStats.push([bonusId,
                                       param[1].to_i * level + param[0].to_i,
                                       param[3].to_i * level + param[2].to_i,
                                       param[5].to_i * level + param[4].to_i,
                                       m
                        ])
                    end
                end
            }
        }
        description = ""
        if item['description'] != nil
            description = "*" + item['description']["en"] + "*"
        end
        (item['title'] != nil) ? title = item['title']["en"] : title = "undefined"
        sortedStats = []
        $exampleSort.each_with_index { |idExample, indexExample|
            tmpStats.each { |stat|
                if stat[0] == idExample
                    sortedStats[indexExample] = stat
                end
            }
        }
        sortedStats = sortedStats.reject! {|stat| stat.nil? }
        level = item['definition']['item']['level'].to_i
        if item['definition']['item']['baseParameters']['itemTypeId'] == 582
            level += 50
        end
        tmpItem = Item.new(
            title,
            rarity,
            color,
            level,
            description,
            sortedStats,
            "https://s.ankama.com/www/static.ankama.com/wakfu/portal/game/item/115/" + item['definition']['item']['graphicParameters']['gfxId'].to_s + ".png"
        )
        $listItemsEN.push tmpItem
    }
    puts "Itemlist finished, enjoy the bot !"
end

loadItemList()

bot = Discordrb::Commands::CommandBot.new token: ENV["token"], prefix: "w!", advanced_functionality: true, compress_mode: :large

bot.command(:almanax, min_args: 0, max_args: 1, description: I18n.t(:almanaxCommand)) do |event, *args|
    if !args
        checkLanguage(event,client)
        message = I18n.t(:almanaxEvent)
        today = Date.today
        compare = Date.new(2019, 11, 21)
        difference = (today - compare).to_i
        if difference % 5 == 0
            message += I18n.t(:prospecting)
        elsif difference % 5 == 1
            message += I18n.t(:craft)
        elsif difference % 5 == 2
            message += I18n.t(:XPHarvest)
        elsif difference %5 == 3
            message += I18n.t(:FarmHarvest)
        elsif difference %5 == 4
            message += I18n.t(:wisdom)
        end
        event << event.user.name + I18n.t(:checkDM)
        event.user.pm(message)
    else
        if args[0] == 'ici' || args[0] == 'here'
            checkLanguage(event,client)
            message = I18n.t(:almanaxEvent)
            today = Date.today
            compare = Date.new(2019, 11, 21)
            difference = (today - compare).to_i
            if difference % 5 == 0
                message += I18n.t(:prospecting)
            elsif difference % 5 == 1
                message += I18n.t(:craft)
            elsif difference % 5 == 2
                message += I18n.t(:XPHarvest)
            elsif difference %5 == 3
                message += I18n.t(:FarmHarvest)
            elsif difference %5 == 4
                message += I18n.t(:wisdom)
                event << message
            end
        else
            event << I18n.t(:correctUsage) + "w!almanax [ici/here]"
        end
    end
end

bot.command(:object, min_args: 2, description: I18n.t(:objectCommand)) do |event, *args|
    findObject = false
    findRarity = false
    moreArgs = ""
    level = ""
    listItem = checkLanguage(event,client)

    if args.length > 2
        moreArgs = args.join(' ')
        moreArgs.slice!(args[0] + ' ')
    else
        moreArgs = args[1]
    end

    listItem.each { |item|
        if moreArgs.downcase === item.name.downcase
            findObject = true
            messageEmbed = ""
            if args[0].downcase == item.rarity.downcase
                findRarity = true
                event.send_embed do |embed|
                    embed.title = item.name + " " + I18n.t(:level) + " " + item.level.to_s
                    embed.description = item.getStatsMessage
                    embed.color = item.color
                    embed.add_field(name: "Description: ", value: item.description)
                    embed.image = Discordrb::Webhooks::EmbedImage.new(url: item.image)
                end
            end
        end
    }
    if !findObject
        event << I18n.t(:noObject)
    end
    if findObject && !findRarity
        event << I18n.t(:noRarity)
    end
end

bot.command(:compare, max_args: 4, description: I18n.t(:compareCommand)) do |event, *args|
    findObject1 = false
    findRarity1 = false
    findObject2 = false
    findRarity2 = false
    item1 = nil
    item2 = nil
    listItems = checkLanguage(event, client)

    #item 1
    listItems.each { |item|
        if args[1].downcase === item.name.downcase
            findObject1 = true
            if args[0].downcase == item.rarity.downcase
                findRarity1 = true
                item1 = item
            end
        end
    }
    if !findObject1
        event << args[1] + I18n.t(:noObject)
    end
    if findObject1 && !findRarity1
        event << args[1] + ", " + args[0] + I18n.t(:noRarity)
    end

    #item 2
    listItems.each { |item|
        if args[3].downcase === item.name.downcase
            findObject2 = true
            messageEmbed = ""
            if args[2].downcase == item.rarity.downcase
                findRarity2 = true
                item2 = item
            end
        end
    }
    unless findObject2
        event << args[3] + I18n.t(:noObject)
    end
    if findObject2 && !findRarity2
        event << args[3] + ", " + args[2] + I18n.t(:noRarity)
    end
    if findObject1 && findObject2
        tabStats1 = []
        tabStats2 = []
        item1.stats.each { |stat1|
            id_found = false
            item2.stats.each { |stat2|
                if stat1[0] == stat2[0]
                    id_found = true
                    if stat1[2] == stat2[2]
                        tabStats1.push [stat1[0], stat1[1] - stat2[1], 0]
                    else
                        tabStats1.push [stat1[0], stat1[1] - stat2[1], stat1[2] - stat2[2]]
                    end
                end
            }
            if !id_found
                tabStats1.push [stat1[0], stat1[1], stat1[2]]
            end
        }
        item2.stats.each { |stat1|
            id_found = false
            item1.stats.each { |stat2|
                if stat1[0] == stat2[0]
                    id_found = true
                    if stat1[2] == stat2[2]
                        tabStats2.push [stat1[0], stat1[1] - stat2[1], 0]
                    else
                        tabStats2.push [stat1[0], stat1[1] - stat2[1], stat1[2] - stat2[2]]
                    end
                end
            }
            if !id_found
                tabStats2.push [stat1[0], stat1[1], stat1[2]]
            end
        }
        i = 0
        j = 0
        tmpMessage1 = ""
        tmpMessage2 = ""
        item1.stats.each { |stat|
            indicator = ""
            if tabStats1[i][1] >= 0
                indicator = "+"
            end
            statmessage = stat[4].to_s
            statmessage += " (" + indicator.to_s + tabStats1[i][1].to_s + ")"
            tmpMessage1 += statmessage + "\n"
            i += 1
        }
        item2.stats.each { |stat|
            indicator = ""
            if tabStats2[j][1] >= 0
                indicator = "+"
            end
            statmessage = stat[4].to_s
            statmessage += " (" + indicator.to_s + tabStats2[j][1].to_s + ")"
            if tabStats2[j][2] != 0
                statmessage += "(" + tabStats2[j][2].to_s + ")"
            end
            tmpMessage2 += statmessage + "\n"
            j += 1
        }
        event.send_embed do |embed|
            embed.title = I18n.t(:itemVS) + item1.name + " " + item1.rarity + " VS " + item2.name + " " + item2.rarity
            embed << Discordrb::Webhooks::EmbedField.new(name: item1.name, value: tmpMessage1, inline: true)
            embed << Discordrb::Webhooks::EmbedField.new(name: item2.name, value: tmpMessage2, inline: true)
        end
    end
end

bot.command(:search, description: I18n.t(:searchCommand)) do |event, *args|
    findObject = false
    listFound = []
    listItem = checkLanguage(event, client)

    listItem.each { |item|
        if item.name.downcase.include?(args.join(" ").downcase)
            findObject = true
            listFound.push(item)
        end
    }
    if !findObject
        event << I18n.t(:noObject)
    else
        if listFound.length == 1
            event.send_embed do |embed|
                embed.title = listFound[0].name + " " +I18n.t(:level) + " " + listFound[0].level.to_s
                embed.description = listFound[0].getStatsMessage
                embed.color = listFound[0].color
                embed.add_field(name: "Description: ", value: listFound[0].description)
                embed.image = Discordrb::Webhooks::EmbedImage.new(url: listFound[0].image)
            end
        else
            description = ""
            i = 1
            listFound.each { |itemFound|
                description += i.to_s + ") " + itemFound.name + " " + itemFound.rarity + " " + I18n.t(:level) + " " + itemFound.level.to_s + "\n"
                i += 1
            }
            event.send_embed do |embed|
                embed.title = I18n.t(:chooseNumber)
                embed.description = description
            end
            event.user.await(:guess) do |eventGuess|
                guess = eventGuess.message.content.to_i
                if(guess < 1 or guess > listFound.length)
                    guessEvent.respond I18n.t(:chooseNumber)
                    false
                else
                    event.send_embed do |embed|
                        embed.title = listFound[guess - 1].name + " " +I18n.t(:level) + " " + listFound[guess - 1].level.to_s
                        embed.description = listFound[guess - 1].getStatsMessage
                        embed.color = listFound[guess - 1].color
                        embed.add_field(name: "Description: ", value: listFound[guess - 1].description)
                        embed.image = Discordrb::Webhooks::EmbedImage.new(url: listFound[guess - 1].image)
                    end
                end
            end
        end
    end
    I18n.t(:searchEnd)
end


bot.command(:setLanguage, min_args: 1, max_args: 1, description: I18n.t(:setLanguageCommand)) do |event, *args|
    if(args[0] == "fr" or args[0] == "en")
        language = ""
        /
        line_file = 0
        id_found = false
        id_server = event.server.id
        File.open("config.txt", "w+") { |file_lang|
            file_lang.each_line do |line|
                if id_server == line.split(":")[0]
                    id_found = true
                    line.puts(id_server + ":" + args[0])
                    language = args[0]
                end
                line_file += 1
            end
            if(id_found == false)
                language = args[0]
                file_lang.write(id_server.to_s + ":" + language + "\n")
            end
        }
        /
        if(collection.find("id_server" => event.server.id).first())
            result = collection.update_one({"id_server" => event.server.id}, 
                {"$set" => 
                    {
                        :language => args[0]
                    } 
                }
            )
        else
            doc = {
                id_server: event.server.id,
                language: args[0]
              }
            result = collection.insert_one(doc)
        end

        I18n.locale = args[0]
        event << I18n.t(:setLang1) + args[0] + I18n.t(:setLang2)
    else
        event << I18n.t(:wrongLanguage)
    end
end

bot.command(:version, max_args: 0, description: I18n.t(:versionCommand)) do |event|
    file = File.open("version.txt", "r")
    message = ""
    file.each_line do |line|
        message += line
    end 
    message
end
bot.run
