# by Elio-Centrique, All right Reserved 2019

# frozen_string_literal: false
# encoding: UTF-8
# This bot has various commands that show off CommandBot.

require 'json'
require 'discordrb'
require 'discordrb/webhooks'
require 'i18n'

WEBHOOK_URL = 'https://discordapp.com/api/webhooks/637399313785290752/q081E5Gg6HQhxi4MNMhNaOZ9Bqe-aQeorNfZg_qGE0ptoMflsoY-v4ASILfKAepx89Dn'.freeze

client = Discordrb::Webhooks::Client.new(url: WEBHOOK_URL)
client.execute do |builder|
  builder.content = 'Almanax'
  builder.add_embed do |embed|
    embed.title = 'Embed title'
    embed.description = 'Embed description'
    embed.timestamp = Time.now
  end
end


file = File.read("config.txt")
file_data = file.split

language = file_data[0]
I18n.load_path << Dir[File.expand_path("locale") + "/*.yml"]
I18n.default_locale = language.to_sym

bot = Discordrb::Commands::CommandBot.new token: 'NTA3NTUzMTQwMzMwMjAxMDg5.Xc1eaQ.-gOWyhTLDtEgPh0yjeFLeoVlx3I', prefix: "w!", advanced_functionality: true

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

    for item in jsonItem
        if moreArgs.downcase === item['title'][language].downcase
            findObject = true
            level = item['definition']['item']['level']
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
            messageEmbed = ""
            if args[0].downcase == rarity.downcase
                findRarity = true
                itemlink = "https://s.ankama.com/www/static.ankama.com/wakfu/portal/game/item/115/" + item['definition']['item']['graphicParameters']['gfxId'].to_s + ".png"
                for bonus in item['definition']['equipEffects']
                    bonusId = bonus['effect']['definition']['actionId']
                    for action in jsonAction
                        if bonusId === action['definition']['id']
                            param = bonus['effect']['definition']['params']
                            level = item['definition']['item']['level'].to_i
                            m = action['description'][language].encode("ISO-8859-1").encode('utf-8')
                            m.gsub! '[~3]?[#1] Maîtrise [#3]:', ""
                            m.gsub! '[~3]?[#1] Mastery [#3]:', ""
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
                            messageEmbed += m + "\n"
                        end
                    end
                end
                event.send_embed do |embed|
                    embed.title = moreArgs + " " +I18n.t(:level) + " " + level.to_s
                    embed.description = messageEmbed
                    embed.color = color
                    embed.add_field(name: "Description: ", value: "*" + item['description'][language] + "*")
                    embed.image = embed.image = Discordrb::Webhooks::EmbedImage.new(url: itemlink)
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
    level1 = ""
    level2 = ""


    #item 1
    for item in jsonItem
        if args[1].downcase === item['title'][language].downcase
            findObject1 = true
            level1 = item['definition']['item']['level']
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
            messageEmbed = ""
            if args[0].downcase == rarity.downcase
                findRarity1 = true
                linkpart = item['definition']['item']['graphicParameters']['gfxId']
                for bonus in item['definition']['equipEffects']
                    bonusId = bonus['effect']['definition']['actionId']
                    for action in jsonAction
                        if bonusId === action['definition']['id']
                            param = bonus['effect']['definition']['params']
                            level = item['definition']['item']['level'].to_i
                            m = action['description'][language].encode("ISO-8859-1").encode('utf-8')
                            m.gsub! '[~3]?[#1] Maîtrise [#3]:', ""
                            m.gsub! '[~3]?[#1] Mastery [#3]:', ""
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
                            messageEmbed += m + "\n"
                        end
                    end
                end
                event.send_embed do |embed|
                    embed.title = args[1] + " " + I18n.t(:level) + " " + level1.to_s
                    embed.description = messageEmbed
                    embed.color = color
                    embed.add_field(name: "Description: ", value: "*" + item['description'][language] + "*")
                    embed.image = Discordrb::Webhooks::EmbedImage.new(url: "https://s.ankama.com/www/static.ankama.com/wakfu/portal/game/item/115/" + linkpart.to_s + ".png")
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
    for item in jsonItem
        if args[3].downcase === item['title'][language].downcase
            findObject2 = true
            level2 = item['definition']['item']['level']
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
            messageEmbed = ""
            if args[2].downcase == rarity.downcase
                findRarity2 = true
                linkpart = item['definition']['item']['graphicParameters']['gfxId']
                for bonus in item['definition']['equipEffects']
                    bonusId = bonus['effect']['definition']['actionId']
                    for action in jsonAction
                        if bonusId === action['definition']['id']
                            param = bonus['effect']['definition']['params']
                            level = item['definition']['item']['level'].to_i
                            m = action['description'][language].encode("ISO-8859-1").encode('utf-8')
                            m.gsub! '[~3]?[#1] Maîtrise [#3]:', ""
                            m.gsub! '[~3]?[#1] Mastery [#3]:', ""
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
                            messageEmbed += m + "\n"
                        end
                    end
                end
                event.send_embed do |embed|
                    embed.title = args[3] + " " + I18n.t(:level) + " " + level2.to_s
                    embed.description = messageEmbed
                    embed.color = color
                    embed.add_field(name: "Description: ", value: "*" + item['description'][language] + "*")
                    embed.image = Discordrb::Webhooks::EmbedImage.new(url: "https://s.ankama.com/www/static.ankama.com/wakfu/portal/game/item/115/" + linkpart.to_s + ".png")
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
    conf_file = File.read('config.txt')
    conf_data = conf_file.split
    File.write('config.txt', args[0])
    language = args[0]
    I18n.default_locale = args[0]
    event << I18n.t(:setLang1) + args[0] + I18n.t(:setLang2)
end

bot.command(:version, max_args: 0, description: I18n.t(:versionCommand)) do |event|
    file = File.open("version.txt").read
    file.each_line do |line|
        event << line
    end 
end

bot.run