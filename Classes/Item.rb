class Item    
    def initialize(name, rarity, color, level, description, stats, statsmessages, image)
        @name = name
        @rarity = rarity
        @color = color
        @level = level
        @description = description
        @stats = stats
        @statsmessages = statsmessages
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

    def getStatsMessage
        message = ""
        @statsmessages.each { |stat|
            message += stat + "\n"
        }
        return message
    end

    def statsmessages
        @statsmessages
    end

    def setStats(stats)
        @stats = stats
    end

    def image
        @image
    end

    def stats
        @stats
    end

    def setStatsMessage(statsMessage)
        @statsmessages = statsMessage
    end
end