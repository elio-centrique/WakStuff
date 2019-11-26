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