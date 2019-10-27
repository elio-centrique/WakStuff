const RARITY = {
    1: 'commun',
    2: 'rare',
    3: 'mythique',
    4: 'legendaire',
    5: 'relique',
    6: 'souvenir',
    7: 'épique'
};

class Item {
    constructor(id, title, level, itemType, action, rarity) {
        this.id = id;
        this.title = title;
        this.level = level;
        this.itemType = itemType;
        this.action = action;
        this.rarity = rarity;
    }
}