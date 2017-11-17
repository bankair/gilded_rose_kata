class ItemWrapper < SimpleDelegator
  def restore!
    return if __getobj__.quality >= 50
    __getobj__.quality += 1
    yield if block_given?
  end

  def degrade!
    return unless quality.positive?
    return if sulfuras?
    __getobj__.quality -= 1
  end

  AGED_BRIE = 'Aged Brie'
  BACKSTAGE_PASSES = 'Backstage passes to a TAFKAL80ETC concert'
  SULFURAS = 'Sulfuras, Hand of Ragnaros'

  def age!
    return if sulfuras?
    __getobj__.sell_in -= 1
  end

  def sulfuras?
    name == SULFURAS
  end
end

def update_aged_brie_or_backstage_passes(item)
  item.restore! do
    if item.name == ItemWrapper::BACKSTAGE_PASSES
      update_backstage_passes(item)
    end
  end
end

def update_backstage_passes(item)
  if item.sell_in < 11
    item.restore!
  end
  if item.sell_in < 6
    item.restore!
  end
end

def update_item(item)
    if item.name == ItemWrapper::AGED_BRIE || item.name == ItemWrapper::BACKSTAGE_PASSES
      update_aged_brie_or_backstage_passes(item)
    else
      item.degrade!
    end

    item.age!

    if item.sell_in < 0

      if item.name == ItemWrapper::AGED_BRIE
        item.restore!
      else
        if item.name == ItemWrapper::BACKSTAGE_PASSES
          item.quality = 0
        else
          item.degrade!
        end
      end
    end
end

def update_quality(items)
  items.each { |item| update_item(ItemWrapper.new(item)) }
end

# DO NOT CHANGE THINGS BELOW -----------------------------------------

Item = Struct.new(:name, :sell_in, :quality)

# We use the setup in the spec rather than the following for testing.
#
# Items = [
#   Item.new("+5 Dexterity Vest", 10, 20),
#   Item.new("Aged Brie", 2, 0),
#   Item.new("Elixir of the Mongoose", 5, 7),
#   Item.new("Sulfuras, Hand of Ragnaros", 0, 80),
#   Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20),
#   Item.new("Conjured Mana Cake", 3, 6),
# ]

